<#escape x as x?html>
<#macro agentTable agent withRole=false>
<table>
	<#if agent.firstName?? || agent.lastName??><tr><th><@s.text name='portal.resource.name'/></th><td>${agent.firstName!} ${agent.lastName!}</td></tr></#if>
	<#if agent.position?? ><tr><th><@s.text name='eml.associatedParties.position'/></th><td>${agent.position!}</td></tr></#if>
	<#if agent.organisation?? ><tr><th><@s.text name='eml.contact.organisation'/></th><td>${agent.organisation!}</td></tr></#if>
	<#if !agent.address.isEmpty()><tr><th><@s.text name='eml.contact.address.address'/></th><td>
	<#if agent.address.address??>${agent.address.address}</#if><#if agent.address.city??>, ${agent.address.city}</#if><#if agent.address.province??>, ${agent.address.province}</#if><#if agent.address.country?? && countries[agent.address.country]?has_content>, ${countries[agent.address.country]!}</#if><#if agent.address.postalCode??>, <@s.text name='eml.contact.address.postalCode'/>: ${agent.address.postalCode}</#if>
	</td></tr></#if>
	<#if agent.email?? || agent.phone??><tr><th><@s.text name='portal.resource.contact'/></th><td><a href="mailto:${agent.email!}">${agent.email!}</a> <#if agent.phone??><@s.text name='portal.resource.tel'/>: ${agent.phone!}</#if></td></tr></#if>
	<#if agent.homepage?? ><tr><th><@s.text name='eml.associatedParties.homepage'/></th><td><a href="${agent.homepage!}">${agent.homepage!}</a></td></tr></#if>
  <#if withRole && roles[agent.role]?has_content>
    <tr>
      <th><@s.text name='eml.associatedParties.role'/></th>
      <td>${roles[agent.role]?cap_first!}</td>
    </tr>
  </#if>
</table>
</#macro>
<#include "/WEB-INF/pages/macros/forms.ftl"/>
<#include "/WEB-INF/pages/inc/header.ftl">
	<title>${resource.title!resource.shortname!}</title>	
<#include "/WEB-INF/pages/inc/menu.ftl">

<div class="grid_24">
<div class="">
<div class="versionTitle">
  <h1 class="withVersion">${eml.title!resource.shortname}<#if managerRights> <a class="edit" href="${baseURL}/manage/resource.do?r=${resource.shortname}"><@s.text name='button.edit'/></a></#if>
  <h1 class="minuscular"><#if eml.intellectualRights?has_content><@s.text name='eml.intellectualRights'/>:&nbsp</th><td><@textWithFormattedLink eml.intellectualRights!no_description/></#if></h1>
  </h1>
                  
  <#if resource.lastPublished??>
    <#-- the existence of parameter version means the version is not equal to the latest published version -->
    <#if version?? && version!=resource.emlVersion><em class="warn"><@s.text name='portal.resource.version'/> ${version}</em> - <a href="${baseURL}/resource.do?r=${resource.shortname}"><@s.text name='portal.resource.version.latest'/></a></#if>
    
  </#if>
</div>
<div id="resourcelogo">
	<#if eml.logoUrl?has_content>
	<img src="${eml.logoUrl}" />
	</#if>
</div>
<p>
<#assign no_description><@s.text name='portal.resource.no.description'/></#assign>
  <@textWithFormattedLink resource.description!no_description/>  
</p>
</div>
<#if resource.lastPublished?? >
  <div class="resourceOverviewPortal" id="metadata">
      <div class="title">
          <div class="head">
            <@s.text name='portal.resource.summary'/>
          </div>
      </div>
      <div class="body">
          <div class="details">
              <table>
                <#if resource.lastPublished??>
                    <tr>
                        <th><@s.text name='eml.pubDate'/></th>
                      <#if eml.pubDate??>
                          <td>${eml.pubDate?date?string.medium}</td>
                      </#if>
                    </tr>
                    <tr>
                        <th><@s.text name='portal.resource.version'/></th>
                        <td><#if version?? && version!=resource.emlVersion>${version} - <a href="${baseURL}/resource.do?r=${resource.shortname}"><@s.text name='portal.resource.version.latest'/></a><#else>${resource.emlVersion} (<@s.text name='portal.resource.latest'/>)</#if></td>
                    </tr>
                  <#if resource.updateFrequency?has_content && frequencies[resource.updateFrequency.identifier]?has_content>
                      <tr>
                          <th><@s.text name='resource.updateFrequency'/></th>
                          <td>${frequencies[resource.updateFrequency.identifier]?cap_first!}<em><#if resource.nextPublished??> (<@s.text name='manage.home.next.publication'/>: ${resource.nextPublished?date?string.medium})</#if></em></td>
                      </tr>
                  </#if>
                    
					<#function elemInArray array elem sep>
					  <#list array?split(sep) as arrayElem>
					    <#if arrayElem == elem>
					    	<#return true>
					  	</#if>
					  </#list>
					  <#return false>
					</#function>
					  
					  <#-- ...Decide whether to show link to DwCA file or not... -->
					  <#assign showDwCA=false/>
					  <#if eml.intellectualRights?has_content>
					  	<#if elemInArray('Libre a nivel interno, Libre a nivel interno con notificación previa, Restringido temporalmente', eml.intellectualRights, ", ") >
						    <#if (Session.curr_user)??>
						    	<#if Session.curr_user.email?ends_with("@humboldt.org.co") && eml.intellectualRights == "Libre a nivel interno" >
						    		<#assign showDwCA=true/>
						    	</#if>
								  <#if (Session.curr_user.email?ends_with("@humboldt.org.co") && eml.intellectualRights != "Libre a nivel interno") || !Session.curr_user.email?ends_with("@humboldt.org.co") >
								  	<#if Session.curr_user.grantedAccessTo?has_content >
								  	  <#if elemInArray(Session.curr_user.grantedAccessTo, resource.shortname, ", ")>
									      <#assign showDwCA=true/>
									    </#if>
							  	  </#if>
							  	</#if>
						    </#if>
						  <#else>	
						    <#assign showDwCA=true/>
						  </#if>	
					  </#if>

				  <#if showDwCA>
				    <#if metadataOnly>
	                  <#-- Archive, EML, and RTF download links include Google Analytics event tracking -->
	                  <#-- e.g. Archive event tracking includes components: _trackEvent method, category, action, label, (int) value -->
	                  <#-- EML and RTF versions can always be retrieved by version number but DWCA versions are only stored if IPT Archive Mode is on -->
	                  <tr>
	                      <th><@s.text name='portal.resource.published.archive'/></th>
	                      <td><a href="${baseURL}/archive.do?r=${resource.shortname}<#if version??>&v=${version}</#if>"
	                             onClick="_gaq.push(['_trackEvent', 'Archive', 'Download', '${resource.shortname}', ${resource.recordsPublished?c!0} ]);"><@s.text name='portal.resource.download'/></a>
	                          (${dwcaFormattedSize}
	                          ) <#if version?? && version!=resource.emlVersion>
	                              <#if recordsPublishedForVersion?? && recordsPublishedForVersion!= 0>
	                                ${recordsPublishedForVersion?c} <@s.text name='portal.resource.records'/>
	                              </#if>
	                            <#else>
	                              ${resource.recordsPublished?c!0} <@s.text name='portal.resource.records'/>
	                            </#if>
	                      </td>
	                  </tr>
                  	</#if>
                  </#if>
                  
                    <tr>
                        <th><@s.text name='portal.resource.published.eml'/></th>
                        <td><a href="${baseURL}/eml.do?r=${resource.shortname}&v=<#if version??>${version}<#else>${resource.emlVersion}</#if>"
                               onClick="_gaq.push(['_trackEvent', 'EML', 'Download', '${resource.shortname}']);"><@s.text name='portal.resource.download'/></a>
                            (${emlFormattedSize})
                        </td>
                    </tr>

                    <tr>
                        <th><@s.text name='portal.resource.published.rtf'/></th>
                        <td><a href="${baseURL}/rtf.do?r=${resource.shortname}&v=<#if version??>${version}<#else>${resource.emlVersion}</#if>"
                               onClick="_gaq.push(['_trackEvent', 'RTF', 'Download', '${resource.shortname}']);"><@s.text name='portal.resource.download'/></a>
                            (${rtfFormattedSize})
                        </td>
                    </tr>
                  <#if resource.status=="REGISTERED">
                      <tr>
                          <th><@s.text name='portal.resource.organisation.key'/></th>
                          <td><a href="${cfg.portalUrl}/dataset/${resource.key}" target="_blank">${resource.key}</a></td>
                      </tr>
                    <#if resource.organisation??>
                        <tr>
                            <th><@s.text name='portal.resource.organisation.name'/></th>
                            <#-- Warning: in dev mode organization link goes to /organization (GBIF Registry console), in prod mode the link goes to /publisher (GBIF Portal) -->
                            <#if cfg.getRegistryType() =='DEVELOPMENT'>
                              <td><a href="${cfg.portalUrl}/organization/${resource.organisation.key}" target="_blank">${resource.organisation.name!"Organisation"}</a></td>
                            <#else>
                              <td><a href="${cfg.portalUrl}/publisher/${resource.organisation.key}" target="_blank">${resource.organisation.name!"Organisation"}</a></td>
                            </#if>
                        </tr>
                        <tr>
                          <th><@s.text name='portal.resource.organisation.node'/></th>
                          <td><a href="${cfg.portalUrl}/node/${resource.organisation.nodeKey!"#"}" target="_blank">${resource.organisation.nodeName!}</a></td>
                        </tr>
                    </#if>
                  <#else>
                      <tr>
                          <th><@s.text name='portal.resource.organisation.key'/></th>
                          <td><@s.text name='manage.home.not.registered'/></td>
                      </tr>
                  </#if>
                 <#else>
                  <tr>
                    <th><@s.text name='eml.pubDate'/></th>
                    <td><@s.text name='portal.resource.published.never'/></td>
                  </tr>
                </#if>
              </table>
          </div>
      </div>
      <div class="clearfix"></div>
  </div>
</#if>

<#if eml.subject?has_content>
  <div class="resourceOverviewPortal">
      <div class="title">
          <div class="head">
            <@s.text name='portal.resource.summary.keywords'/>
          </div>
      </div>
      <div class="body">
          <div class="details">
            <@textWithFormattedLink eml.subject!no_description/>
          </div>
      </div>
      <div class="clearfix"></div>
  </div>
</#if>

<#if (eml.metadataLanguage?has_content && languages[eml.metadataLanguage]?has_content) || (eml.language?has_content && languages[eml.language]?has_content)>
  <div class="resourceOverviewPortal">
      <div class="title">
          <div class="head">
            <@s.text name='rtf.language'/>
          </div>
      </div>
      <div class="body">
          <div class="details">
              <table>
                <#if eml.metadataLanguage?has_content && languages[eml.metadataLanguage]?has_content>
                    <tr>
                        <th><@s.text name='eml.metadataLanguage'/></th>
                        <td>${languages[eml.metadataLanguage]?cap_first!}</td>
                    </tr>
                </#if>
                <#if eml.language?has_content && languages[eml.language]?has_content>
                    <tr>
                        <th><@s.text name='eml.language'/></th>
                        <td>${languages[eml.language]?cap_first!}</td>
                    </tr>
                </#if>
              </table>
          </div>
      </div>
      <div class="clearfix"></div>
  </div>
</#if>

<#if eml.distributionUrl?? || eml.physicalData?has_content >
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='manage.metadata.physical.title'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">
      		<table>
          		<#if eml.distributionUrl??><tr><th><@s.text name='eml.distributionUrl'/></th><td><a href="${eml.distributionUrl!}">${eml.distributionUrl!}</a></td></tr></#if>
		<#if (eml.physicalData?size > 0 )>
			<#list eml.physicalData as item>
				<#assign link=eml.physicalData[item_index]/>
				<tr><th>${link.name!}</th><td><a href="${link.distributionUrl}">${link.distributionUrl!"?"}</a>
				<#if link.charset?? || link.format?? || link.formatVersion??> 
				${link.charset!} ${link.format!} ${link.formatVersion!}
				</#if>
				</td></tr>
			</#list>
		</#if>
      		</table>
      	</div>
  </div>
  <div class="clearfix"></div>
</div>
</#if>

<#if eml.contact.organisation?has_content || eml.contact.lastName?has_content || eml.contact.position?has_content>
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='eml.contact'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">      		
      		<@agentTable eml.contact />
      	</div>
  </div>
  <div class="clearfix"></div>
  
</div>
</#if>

<#if eml.getResourceCreator().organisation?has_content || eml.getResourceCreator().lastName?has_content || eml.getResourceCreator().position?has_content>
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='portal.resource.creator'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">      		
      		<@agentTable eml.getResourceCreator() />
      	</div>
  </div>
  <div class="clearfix"></div>
  
</div>
</#if>

<#if eml.getMetadataProvider().organisation?has_content || eml.getMetadataProvider().lastName?has_content || eml.getMetadataProvider().position?has_content>
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='portal.metadata.provider'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">
      		<@agentTable eml.getMetadataProvider() />
      	</div>
  </div>
  <div class="clearfix"></div>
  
</div>
</#if>

  <#if (eml.associatedParties?size > 0 )>
    <#list eml.associatedParties as item>

    <div class="resourceOverviewPortal">
      <div class="title">
        <div class="head">
          <#assign num = item_index + 1 />
          <@s.text name="manage.metadata.parties.title.numbered"><@s.param>${num}</@s.param></@s.text>
        </div>
      </div>
      <div class="body">
        <div class="details">
          <@agentTable item true/>
        </div>
      </div>
      <div class="clearfix"></div>
    </div>
    </#list>
  </#if>

<#if eml.geospatialCoverages[0]??>
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='manage.metadata.geocoverage.title'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">
      		<table>
          		<tr><th><@s.text name='eml.geospatialCoverages.description'/></th><td><@textWithFormattedLink eml.geospatialCoverages[0].description!no_description/></td></tr>
      			<tr><th><@s.text name='eml.geospatialCoverages.boundingCoordinates'/></th><td>${eml.geospatialCoverages[0].boundingCoordinates.min.latitude}, ${eml.geospatialCoverages[0].boundingCoordinates.max.latitude} / ${eml.geospatialCoverages[0].boundingCoordinates.min.longitude}, ${eml.geospatialCoverages[0].boundingCoordinates.max.longitude} <@s.text name='eml.geospatialCoverages.boundingCoordinates.indicator'/></td></tr>
      		</table>
      	</div>
  </div>
  <div class="clearfix"></div>
  
</div>
</#if>

  <#if ((organizedCoverages?size > 0))>
  <div class="resourceOverviewPortal">
    <div class="title">
      <div class="head">
        <@s.text name='manage.metadata.taxcoverage.title'/>
      </div>
    </div>
    <div class="body">
      <div class="details">
        <#list organizedCoverages as item>
          <table>
            <tr>
              <th><@s.text name='eml.taxonomicCoverages.description'/></th>
              <td><@textWithFormattedLink item.description!no_description/></td>
            </tr>
          </table>
          <table id="taxonKeywords">
            <#list item.keywords as k>
              <#if k.rank?has_content && ranks[k.rank?string]?has_content && (k.displayNames?size > 0) >
                <tr>
                <#-- 1st col, write rank name once. Avoid problem accessing "class" from map - it displays "java.util.LinkedHashMap" -->
                  <#if k.rank?lower_case == "class">
                    <th>Class</th>
                  <#else>
                    <th>${ranks[k.rank?html]?cap_first!}</th>
                  </#if>
                <#-- 2nd col, write comma separated list of names in format: scientific name (common name) -->
                  <td>
                    <#list k.displayNames as name>
                    ${name}<#if name_has_next>, </#if>
                    </#list>
                  </td>
                </tr>
              </#if>
            </#list>
          </table>
        <#-- give some space between taxonomic coverages -->
            <#if item_has_next></br></#if>
        </#list>
      </div>
    </div>
    <div class="clearfix"></div>
  </div>
  </#if>

<#assign size=eml.temporalCoverages?size/>
<#if (size > 0 )>
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='manage.metadata.tempcoverage.title'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">
      	<table>
			<#list eml.temporalCoverages as item>
			<tr>
			<td>
				<div>
				<table>
					<#if ("${item.type}" == "DATE_RANGE") && eml.temporalCoverages[item_index].startDate?? && eml.temporalCoverages[item_index].endDate?? >
						<tr><th><@s.text name='eml.temporalCoverages.startDate'/> / <@s.text name='eml.temporalCoverages.endDate'/></th><td>${eml.temporalCoverages[item_index].startDate?date} / ${eml.temporalCoverages[item_index].endDate?date}</td></tr>
					<#elseif "${item.type}" == "SINGLE_DATE" && eml.temporalCoverages[item_index].startDate?? >
						<tr><th><@s.text name='eml.temporalCoverages.startDate'/></th><td>${eml.temporalCoverages[item_index].startDate?date}</td></tr>
					<#elseif "${item.type}" == "FORMATION_PERIOD" && eml.temporalCoverages[item_index].formationPeriod?? >
						<tr><th><@s.text name='eml.temporalCoverages.formationPeriod'/></th><td>${eml.temporalCoverages[item_index].formationPeriod}</td></tr>
					<#elseif eml.temporalCoverages[item_index].livingTimePeriod??> <!-- LIVING_TIME_PERIOD -->
						<tr><th><@s.text name='eml.temporalCoverages.livingTimePeriod'/></th><td>${eml.temporalCoverages[item_index].livingTimePeriod!}</td></tr>
					</#if>
				</table>
				</div>
			</td>
			</tr>
			</#list>
		</table>
      	</div>
  </div>
  <div class="clearfix"></div>
</div>
</#if>

<#if eml.project.personnel.lastName??>
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='manage.metadata.project.title'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">
      		<table>
          		<#if eml.project.title?has_content><tr><th><@s.text name='eml.project.title'/></th><td><@textWithFormattedLink eml.project.title!/></td></tr></#if>
              <#if eml.project.personnel??>
                <#assign personnel = eml.project.personnel>
                <#if personnel.lastName?has_content><tr>
                    <th>&#40;<@s.text name='rtf.project.personnel'/>&#41;&nbsp;<@s.text name='portal.resource.name'/></th>
                    <td>${personnel.firstName!} ${personnel.lastName!}</td>
                </tr>
                </#if>
                <#if roles[personnel.role?string]?has_content>
                  <tr>
                    <th>&#40;<@s.text name='rtf.project.personnel'/>&#41;&nbsp;<@s.text name='eml.associatedParties.role'/></th>
                    <td>${roles[personnel.role?string]!}</td>
                  </tr>
                </#if>
              </#if>
          		<#if eml.project.funding?has_content><tr><th><@s.text name='eml.project.funding'/></th><td><@textWithFormattedLink eml.project.funding/></td></tr></#if>
          		<#if eml.project.studyAreaDescription.descriptorValue?has_content><tr><th><@s.text name='eml.project.studyAreaDescription.descriptorValue'/></th><td><@textWithFormattedLink eml.project.studyAreaDescription.descriptorValue/></td></tr></#if>
          		<#if eml.project.designDescription?has_content><tr><th><@s.text name='eml.project.designDescription'/></th><td><@textWithFormattedLink eml.project.designDescription/></td></tr></#if>
      		</table>
      	</div>
  </div>
  <div class="clearfix"></div>
</div>
</#if>

<#if eml.studyExtent?has_content || eml.sampleDescription?has_content || eml.qualityControl?has_content || (eml.methodSteps?? && (eml.methodSteps?size>=1) && eml.methodSteps[0]?has_content) >
<div class="resourceOverviewPortal">
  <div class="title">
  	<div class="head">
        <@s.text name='manage.metadata.methods.title'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">
      		<table>
          		<#if eml.studyExtent?has_content><tr><th><@s.text name='eml.studyExtent'/></th><td><@textWithFormattedLink eml.studyExtent/></td></tr></#if>
          		<#if eml.sampleDescription?has_content><tr><th><@s.text name='eml.sampleDescription'/></th><td><@textWithFormattedLink eml.sampleDescription/></td></tr></#if>
          		<#if eml.qualityControl?has_content><tr><th><@s.text name='eml.qualityControl'/></th><td><@textWithFormattedLink eml.qualityControl/></td></tr></#if>
          		<#list eml.methodSteps as item>
                <#if (eml.methodSteps[item_index]?has_content) >
                  <tr><th><@s.text name='eml.methodSteps'/> ${item_index+1}</th><td><@textWithFormattedLink eml.methodSteps[item_index]/></td></tr>
                </#if>
          		</#list>
      		</table>
      	</div>
  </div>
  <div class="clearfix"></div>
</div>
</#if>

<#if (eml.citation?? && (eml.citation.citation?has_content || eml.citation.identifier?has_content)) || eml.bibliographicCitationSet.bibliographicCitations?has_content>
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='manage.metadata.citations.title'/>
  	</div>
  </div>
  <div class="body">
    <div class="details">
      <table>
        <#if eml.citation?has_content>
          <#if eml.citation.identifier?has_content>
            <tr>
              <th><@s.text name='eml.citation.identifier'/></th>
                <td><@textWithFormattedLink eml.citation.identifier!/></td>
            </tr>
          </#if>
          <tr>
            <th><@s.text name='eml.citation.citation'/></th>
            <td><@textWithFormattedLink eml.citation.citation/></td>
          </tr>
        </#if>
      </table>
          	
   			<#assign itemTitle><@s.text name='eml.bibliographicCitationSet.bibliographicCitations.citation'/></#assign>
          	<table>
       		<#list eml.bibliographicCitationSet.bibliographicCitations as item>
       			<tr>				
	          	<table>
             <#if item.citation?has_content>
               <#if item.identifier?has_content>
                 <tr>
                   <th><@s.text name='eml.bibliographicCitationSet.bibliographicCitations.identifier'/></th>
                   <td><@textWithFormattedLink item.identifier!/></td>
                 </tr>
               </#if>
               <tr>
                 <th><@s.text name='eml.bibliographicCitationSet.bibliographicCitations.citation'/></th>
                 <td><@textWithFormattedLink item.citation/></td>
               </tr>
            </#if>
	      	</table>
				</tr>
       		</#list>
       		</table>
      	</div>
  </div>
  <div class="clearfix"></div>
</div>
</#if>

<#if eml.collectionName?has_content || eml.collectionId?has_content || eml.parentCollectionId?has_content || eml.specimenPreservationMethod?has_content || eml.jgtiCuratorialUnits?has_content >
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='manage.metadata.collections.title'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">
      		<table>
          		<#if eml.collectionName?has_content><tr><th><@s.text name='eml.collectionName'/></th><td>${eml.collectionName!}</td></tr></#if>
          		<#if eml.collectionId?has_content><tr><th><@s.text name='eml.collectionId'/></th><td>${eml.collectionId!}</td></tr></#if>
          		<#if eml.parentCollectionId?has_content><tr><th><@s.text name='eml.parentCollectionId'/></th><td>${eml.parentCollectionId!}</td></tr></#if>
          		<#if eml.specimenPreservationMethod?has_content && preservationMethods[eml.specimenPreservationMethod]?has_content >
                <tr>
                  <th><@s.text name='eml.specimenPreservationMethod'/></th>
                  <td>${preservationMethods[eml.specimenPreservationMethod]?cap_first!}</td>
                </tr>
              </#if>
          	</table>
          	
        	<table>
        	<#list eml.jgtiCuratorialUnits as item>
				<tr>				
				<#assign itemTitle><@s.text name='manage.metadata.collections.curatorialUnits.item'/></#assign>
				<th class="title">${itemTitle?upper_case} ${item_index+1}</th>
				<td>
		       		<table>	
         		   		<#if item.type=="COUNT_RANGE">
          					<tr><th><@s.text name='eml.jgtiCuratorialUnits.rangeStart'/></th><td>${eml.jgtiCuratorialUnits[item_index].rangeStart}</td></tr>
    						<tr><th><@s.text name='eml.jgtiCuratorialUnits.rangeEnd'/></th><td>${eml.jgtiCuratorialUnits[item_index].rangeEnd}</td></tr>
    						<tr><th><@s.text name='eml.jgtiCuratorialUnits.unitType'/></th><td>${eml.jgtiCuratorialUnits[item_index].unitType}</td></tr>
    					<#else>
    						<tr><th><@s.text name='eml.jgtiCuratorialUnits.rangeMean'/></th><td>${eml.jgtiCuratorialUnits[item_index].rangeMean}</td></tr>
    						<tr><th><@s.text name='eml.jgtiCuratorialUnits.uncertaintyMeasure'/></th><td>${eml.jgtiCuratorialUnits[item_index].uncertaintyMeasure}</td></tr>
    						<tr><th><@s.text name='eml.jgtiCuratorialUnits.unitType'/></th><td>${eml.jgtiCuratorialUnits[item_index].unitType}</td></tr>
   						</#if>
    	  			</table>
									
				</td>
				</tr>
	   		</#list>
	   		</table>
      	</div>
  </div>
  <div class="clearfix"></div>
</div>
</#if>

<#--
<#if (eml.keywords?size > 0 )>
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='manage.metadata.keywords.title'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">
		<#list eml.keywords as item>
			<div>
			<#assign itemTitle><@s.text name='manage.metadata.keywords.item'/></#assign>
			<div class="head">${itemTitle?upper_case} ${item_index+1}</div>
      		<table>
				<tr><th><@s.text name='eml.keywords.keywordThesaurus'/></th><td>${eml.keywords[item_index].keywordThesaurus!}</td></tr>
				<tr><th><@s.text name='eml.keywords.keywordsString'/></th><td>${eml.keywords[item_index].keywordsString!}</td></tr>
			</table>
      		
			</div>
		</#list>
      	</div>
  </div>
  <div class="clearfix"></div>
</div>
</#if>
-->

<#if (eml.alternateIdentifiers?size > 0 )>
<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='manage.metadata.alternateIdentifiers.title'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">
      		<table>
          		<#list eml.alternateIdentifiers as item>
          			<tr><td><@textWithFormattedLink eml.alternateIdentifiers[item_index]!/></td></tr>
          		</#list>
      		</table>
      	</div>
  </div>
  <div class="clearfix"></div>
</div>
</#if>

<div class="resourceOverviewPortal">	
  <div class="title">
  	<div class="head">
        <@s.text name='manage.metadata.additional.title'/>
  	</div>
  </div>
  <div class="body">
      	<div class="details">
      		<table>
          		<#if eml.hierarchyLevel?has_content><tr><th><@s.text name='eml.hierarchyLevel'/></th><td>${eml.hierarchyLevel!}</td></tr></#if>
          		<#if eml.purpose?has_content><tr><th><@s.text name='eml.purpose'/></th><td><@textWithFormattedLink eml.purpose/></td></tr></#if>
          		<#if eml.additionalInfo?has_content><tr><th><@s.text name='eml.additionalInfo'/></th><td><@textWithFormattedLink eml.additionalInfo/></td></tr></#if>
      		</table>
      	</div>
  </div>
  <div class="clearfix"></div>
</div>

</div>
<#include "/WEB-INF/pages/inc/footer.ftl">
</#escape>
