/***************************************************************************
 * Copyright 2010 Global Biodiversity Information Facility Secretariat
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 ***************************************************************************/

package org.gbif.ipt.action.manage;

import org.gbif.ipt.config.AppConfig;
import org.gbif.ipt.config.Constants;
import org.gbif.ipt.config.DataDir;
import org.gbif.ipt.config.JdbcSupport;
import org.gbif.ipt.model.Source;
import org.gbif.ipt.model.SourceBase;
import org.gbif.ipt.model.SqlSource;
import org.gbif.ipt.model.TextFileSource;
import org.gbif.ipt.service.AlreadyExistingException;
import org.gbif.ipt.service.ImportException;
import org.gbif.ipt.service.InvalidFilenameException;
import org.gbif.ipt.service.admin.RegistrationManager;
import org.gbif.ipt.service.manage.ResourceManager;
import org.gbif.ipt.service.manage.SourceManager;
import org.gbif.ipt.struts2.SimpleTextProvider;
import org.gbif.utils.file.CompressionUtil;
import org.gbif.utils.file.CompressionUtil.UnsupportedCompressionType;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.google.inject.Inject;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

public class SourceAction extends ManagerBaseAction {

  // logging
  private static final Logger LOG = Logger.getLogger(SourceAction.class);

  private SourceManager sourceManager;
  private JdbcSupport jdbcSupport;
  private DataDir dataDir;
  // config
  private Source source;
  private String rdbms;
  private String problem;
  // file upload
  private File file;
  private String fileContentType;
  private String fileFileName;
  private boolean analyze = false;
  // preview
  private List<String> columns;
  private List<String[]> peek;
  private int peekRows = 10;
  private int analyzeRows = 1000;

  @Inject
  public SourceAction(SimpleTextProvider textProvider, AppConfig cfg, RegistrationManager registrationManager,
    ResourceManager resourceManager, SourceManager sourceManager, JdbcSupport jdbcSupport, DataDir dataDir) {
    super(textProvider, cfg, registrationManager, resourceManager);
    this.sourceManager = sourceManager;
    this.jdbcSupport = jdbcSupport;
    this.dataDir = dataDir;
  }

  public String add() throws IOException {
    boolean replace = false;
    // Are we going to overwrite any source file?
    File ftest = (File) session.get(Constants.SESSION_FILE);
    if (ftest != null) {
      file = ftest;
      fileFileName = (String) session.get(Constants.SESSION_FILE_NAME);
      fileContentType = (String) session.get(Constants.SESSION_FILE_CONTENT_TYPE);
      replace = true;
    }
    // new one
    if (file != null) {
      // uploaded a new file. Is it compressed?
      if (StringUtils.endsWithIgnoreCase(fileContentType, "zip") // application/zip
          || StringUtils.endsWithIgnoreCase(fileContentType, "gzip") || StringUtils
        .endsWithIgnoreCase(fileContentType, "compressed")) { // application/x-gzip
        try {
          File tmpDir = dataDir.tmpDir();
          List<File> files = CompressionUtil.decompressFile(tmpDir, file);
          addActionMessage(getText("manage.source.compressed.files", new String[] {String.valueOf(files.size())}));

          // validate if at least one file already exists to ask confirmation
          if (!replace) {
            for (File f : files) {
              if (resource.getSource(f.getName()) != null) {
                // Since FileUploadInterceptor removes the file once this action is executed,
                // the file need to be copied in the same directory.
                copyFileToOverwrite();
                return INPUT;
              }
            }
          }

          // import each file. The last file will become the id parameter,
          // so the new page opens with that source
          for (File f : files) {
            addDataFile(f, f.getName());
          }
          // manually remove any previous file in session and in temporal directory path
          removeSessionFile();
        } catch (IOException e) {
          LOG.error(e);
          addActionError(getText("manage.source.filesystem.error", new String[] {e.getMessage()}));
          return ERROR;
        } catch (UnsupportedCompressionType e) {
          addActionError(getText("manage.source.unsupported.compression.format"));
          return ERROR;
        } catch (InvalidFilenameException e) {
          addActionError(getText("manage.source.invalidFileName"));
          return ERROR;
        }
      } else {
        // validate if file already exists to ask confirmation
        if (!replace && resource.getSource(fileFileName) != null) {
          // Since FileUploadInterceptor removes the file once this action is executed,
          // the file need to be copied in the same directory.
          copyFileToOverwrite();
          return INPUT;
        }
        try {
          // treat as is - hopefully a simple text or excel file
          addDataFile(file, fileFileName);
        } catch (InvalidFilenameException e) {
          addActionError(getText("manage.source.invalidFileName"));
          return ERROR;
        }

        // manually remove any previous file in session and in temporal directory path
        removeSessionFile();
      }
    }
    return SUCCESS;
  }

  private void addDataFile(File f, String filename) throws InvalidFilenameException {
    // create a new file source
    boolean replaced = resource.getSource(filename) != null;
    try {
      source = sourceManager.add(resource, f, filename);
      saveResource();
      id = source.getName();
      if (replaced) {
        addActionMessage(getText("manage.source.replaced.existing", new String[] {source.getName()}));
      } else {
        addActionMessage(getText("manage.source.added.new", new String[] {source.getName()}));
      }
    } catch (ImportException e) {
      // even though we have problems with this source we'll keep it for manual corrections
      LOG.error("Cannot add source " + filename + ": " + e.getMessage(), e);
      addActionError(getText("manage.source.cannot.add", new String[] {filename, e.getMessage()}));
    } catch (InvalidFilenameException e) {
      // clean session variables used for confirming file overwrite
      removeSessionFile();
      throw e;
    }
  }

  public String cancelOverwrite() {
    removeSessionFile();
    return INPUT;
  }

  /**
   * Copy current file to same directory with different name and insert some temporal session variables.
   */
  private void copyFileToOverwrite() throws IOException {
    File fileNew = new File(file.getParent(), SourceBase.normaliseName(file.getName()) + "-copied.tmp");
    FileUtils.copyFile(file, fileNew);
    session.put(Constants.SESSION_FILE, fileNew);
    session.put(Constants.SESSION_FILE_NAME, fileFileName);
    session.put(Constants.SESSION_FILE_CONTENT_TYPE, fileContentType);
  }

  @Override
  public String delete() {
    if (sourceManager.delete(resource, resource.getSource(id))) {
      addActionMessage(getText("manage.source.deleted", new String[] {id}));
      saveResource();
    } else {
      addActionMessage(getText("manage.source.deleted.couldnt", new String[] {id}));
    }
    return SUCCESS;
  }

  public List<String> getColumns() {
    return columns;
  }

  public TextFileSource getFileSource() {
    if (source instanceof TextFileSource) {
      return (TextFileSource) source;
    }
    return null;
  }

  public Map<String, String> getJdbcOptions() {
    return jdbcSupport.optionMap();
  }

  public boolean getLogExists() {
    return dataDir.sourceLogFile(resource.getShortname(), source.getName()).exists();
  }

  public List<String[]> getPeek() {
    return peek;
  }

  public int getPreviewSize() {
    return peekRows;
  }

  public String getProblem() {
    return problem;
  }

  public String getRdbms() {
    return rdbms;
  }

  public Source getSource() {
    return source;
  }

  public SqlSource getSqlSource() {
    if (source instanceof SqlSource) {
      return (SqlSource) source;
    }
    return null;
  }

  public String peek() {
    if (source == null) {
      return NOT_FOUND;
    }
    peek = sourceManager.peek(source, peekRows);
    columns = sourceManager.columns(source);
    return SUCCESS;
  }

  @Override
  public void prepare() {
    super.prepare();
    if (id != null) {
      source = resource.getSource(id);
      if (source == null) {
        LOG.error("No source with id " + id + " found!");
        addActionError(getText("manage.source.cannot.load", new String[] {id}));
      }
    } else if (file == null) {
      // prepare a new, empty sql source
      source = new SqlSource();
      source.setResource(resource);
      ((SqlSource) source).setRdbms(jdbcSupport.get("mysql"));
    } else {
      // prepare a new, empty file source
      source = new TextFileSource();
      source.setResource(resource);
    }
  }

  /**
   * Remove any previous uploaded file in temporal directory.
   * And clean some session variables used to confirm overwrite action.
   */
  private void removeSessionFile() {
    File fileNew = (File) session.get(Constants.SESSION_FILE);
    if (fileNew != null && fileNew.exists()) {
      fileNew.delete();
    }
    session.remove(Constants.SESSION_FILE);
    session.remove(Constants.SESSION_FILE_NAME);
    session.remove(Constants.SESSION_FILE_CONTENT_TYPE);
  }

  @Override
  public String save() throws IOException {
    // treat jdbc special
    if (source != null && rdbms != null) {
      ((SqlSource) source).setRdbms(jdbcSupport.get(rdbms));
    }
    // existing source
    String result = INPUT;
    if (id != null && source != null) {
      if (this.analyze || !source.isReadable()) {
        problem = sourceManager.analyze(source);
      } else {
        result = SUCCESS;
      }
    } else {
      // new one
      if (file == null) {
        try {
          resource.addSource(source, false);
          id = source.getName();
          if (this.analyze || !source.isReadable()) {
            problem = sourceManager.analyze(source);
          }
        } catch (AlreadyExistingException e) {
          // shouldnt really happen as we validate this beforehand - still catching it here to be safe
          addActionError(getText("manage.source.existing"));
        }
      } else {
        // uploaded a new file
        // create a new file source
        try {
          source = sourceManager.add(resource, file, fileFileName);
          if (resource.getSource(source.getName()) != null) {
            addActionMessage(getText("manage.source.replaced.existing", new String[] {source.getName()}));
          } else {
            addActionMessage(getText("manage.source.added.new", new String[] {source.getName()}));
          }
        } catch (ImportException e) {
          // even though we have problems with this source we'll keep it for manual corrections
          LOG.error("SourceBase error: " + e.getMessage(), e);
          addActionError(getText("manage.source.error", new String[] {e.getMessage()}));
        } catch (InvalidFilenameException e) {
          addActionError(getText("manage.source.invalidFileName"));
          return ERROR;
        }
      }
      id = source.getName();
    }
    saveResource();

    return result;
  }

  public void setAnalyze(String analyze) {
    if (StringUtils.trimToNull(analyze) != null) {
      this.analyze = true;
    }
  }

  public void setFile(File file) {
    this.file = file;
  }

  public void setFileContentType(String fileContentType) {
    this.fileContentType = fileContentType;
  }

  public void setFileFileName(String fileFileName) {
    this.fileFileName = fileFileName;
  }

  public void setRdbms(String jdbc) {
    this.rdbms = jdbc;
    if (source != null && !source.isFileSource()) {
      ((SqlSource) source).setRdbms(jdbcSupport.get(rdbms));
    }
  }

  public void setRows(int previewSize) {
    this.peekRows = previewSize > 0 ? previewSize : 10;
  }

  public void setSource(Source source) {
    this.source = source;
  }

  public String uploadLogo() {
    if (file != null) {
      // remove any previous logo file
      for (String suffix : Constants.IMAGE_TYPES) {
        FileUtils.deleteQuietly(dataDir.resourceLogoFile(resource.getShortname(), suffix));
      }
      // inspect file type
      String type = "jpeg";
      if (fileContentType != null) {
        type = StringUtils.substringAfterLast(fileContentType, "/");
      }
      File logoFile = dataDir.resourceLogoFile(resource.getShortname(), type);
      try {
        FileUtils.copyFile(file, logoFile);
      } catch (IOException e) {
        LOG.warn(e.getMessage());
      }
      // resource.getEml().setLogoUrl(cfg.getResourceLogoUrl(resource.getShortname()));
    }
    return INPUT;
  }

  @Override
  public void validateHttpPostOnly() {
    if (source != null) {
      // ALL SOURCES
      // check if title exists already as a source
      if (StringUtils.trimToEmpty(source.getName()).length() == 0) {
        addFieldError("source.name", getText("validation.required", new String[] {getText("source.name")}));
      } else if (StringUtils.trimToEmpty(source.getName()).length() < 3) {
        addFieldError("source.name", getText("validation.short", new String[] {getText("source.name"), "3"}));
      } else if (id == null && resource.getSources().contains(source)) {
        addFieldError("source.name", getText("manage.source.unique"));
      }
      if (SqlSource.class.isInstance(source)) {
        // SQL SOURCE
        SqlSource src = (SqlSource) source;
        // pure ODBC connections need only a DSN, no server
        if (StringUtils.trimToEmpty(src.getHost()).length() == 0 && rdbms != null && !rdbms.equalsIgnoreCase("odbc")) {
          addFieldError("sqlSource.host", getText("validation.required", new String[] {getText("sqlSource.host")}));
        } else if (StringUtils.trimToEmpty(src.getHost()).length() < 2) {
          addFieldError("sqlSource.host", getText("validation.short", new String[] {getText("sqlSource.host"), "2"}));
        }
        if (StringUtils.trimToEmpty(src.getDatabase()).length() == 0) {
          addFieldError("sqlSource.database",
            getText("validation.required", new String[] {getText("sqlSource.database")}));
        } else if (StringUtils.trimToEmpty(src.getDatabase()).length() < 2) {
          addFieldError("sqlSource.database",
            getText("validation.short", new String[] {getText("sqlSource.database"), "2"}));
        }
      } // else {
      // FILE SOURCE
      // TextFileSource src = (TextFileSource) source;
      // TODO validate file source
      // }
    }
  }
}
