<#escape x as x?html>
<#setting number_format="#####.##">
<#include "/WEB-INF/pages/inc/header.ftl">
<#include "/WEB-INF/pages/macros/metadata.ftl"/>
<script type="text/javascript">
	$(document).ready(function(){
		initHelp();
	});
</script>
<title><@s.text name='manage.metadata.taxcoverage.title'/></title>
<#assign sideMenuEml=true />
<#assign currentMenu="manage"/>
<#include "/WEB-INF/pages/inc/menu.ftl">
<#include "/WEB-INF/pages/macros/forms.ftl"/>

<h1><span class="superscript"><@s.text name='manage.overview.title.label'/></span>
    <a href="resource.do?r=${resource.shortname}" title="${resource.title!resource.shortname}">${resource.title!resource.shortname}</a>
</h1>
<div class="">

<form class="topForm" action="metadata-${section}.do" method="post">
<h2 class="subTitle"><@s.text name='manage.metadata.taxcoverage.title'/></h2>
    <p><@s.text name='manage.metadata.taxcoverage.intro'/></p>
	<div id="items">
		<!-- Adding the taxonomic coverages that already exists on the file -->
		<#assign next_agent_index=0 />
		<#list eml.taxonomicCoverages as item>
			<div id='item-${item_index}' class="item">
				<div class="right">
    				<a id="removeLink-${item_index}" class="removeLink" href="">[ <@s.text name='manage.metadata.removethis'/> <@s.text name='manage.metadata.taxcoverage.item'/> ]</a>
  				</div>
  				<@text  i18nkey="eml.taxonomicCoverages.description" help="i18n" name="eml.taxonomicCoverages[${item_index}].description" />
  				<!-- Taxon list-->
				<!-- a id="taxonsLink-${item_index}" class="show-taxonList" href="" ><@s.text name='manage.metadata.addseveral' /> <@s.text name='manage.metadata.taxcoverage.taxon.items' /></a> -->
				<@link name="taxonsLink-${item_index}" class="show-taxonList" value="manage.metadata.taxcoverage.addSeveralTaxa" help="i18n" i18nkey="manage.metadata.taxcoverage.addSeveralTaxa"/>
				<div id="list-${item_index}" class="half addSeveralTaxa" style="display:none">
					<@text i18nkey="eml.taxonomicCoverages.taxonList" help="i18n" name="taxon-list-${item_index}" value="" />
					<div id="addSeveralTaxaButtons" class="buttons">
						<@s.submit cssClass="button" name="add-button-${item_index}" key="button.add"/>
					</div>
				</div>
				<div id="subItems" class="clearfix">
					<#list item.taxonKeywords as subItem>
						<div id="subItem-${subItem_index}" class="sub-item grid_17 suffix_1 clearfix">
							<div class="third">
								<@input i18nkey="eml.taxonomicCoverages.taxonKeyword.scientificName" name="eml.taxonomicCoverages[${item_index}].taxonKeywords[${subItem_index}].scientificName" requiredField=true />
								<@input i18nkey="eml.taxonomicCoverages.taxonKeyword.commonName" name="eml.taxonomicCoverages[${item_index}].taxonKeywords[${subItem_index}].commonName" />
								<@select i18nkey="eml.taxonomicCoverages.taxonKeyword.rank" name="eml.taxonomicCoverages[${item_index}].taxonKeywords[${subItem_index}].rank" options=ranks value="${eml.taxonomicCoverages[item_index].taxonKeywords[subItem_index].rank!?lower_case}" />
								<#if (item.taxonKeywords ? size == 1) >
									<img id="trash-${item_index}-${subItem_index}" class="trash-icon" src="${baseURL}/images/trash-m.png" style="display: none;">
								<#else>
									<img id="trash-${item_index}-${subItem_index}" class="trash-icon" src="${baseURL}/images/trash-m.png">
								</#if>
							</div>
						</div>
					</#list>
				</div>
				<div style="margin-top:10px;font-size:0.92em;"><a id="plus-subItem-${item_index}" href="" ><@s.text name='manage.metadata.addnew' /> <@s.text name='manage.metadata.taxcoverage.taxon.item' /></a></div>
			</div>
		</#list>
	</div>
	<div class="addNew"><a id="plus" href=""><@s.text name='manage.metadata.addnew' /> <@s.text name='manage.metadata.taxcoverage.item' /></a></div>

	<div class="buttons">
		<@s.submit cssClass="button" name="save" key="button.save"/>
		<@s.submit cssClass="button" name="cancel" key="button.cancel"/>
	</div>
	<!-- internal parameter -->
	<input name="r" type="hidden" value="${resource.shortname}" />
</form>
</div>

<!-- The base form that is going to be cloned every time an user click on the 'add' link -->
<!-- The next divs are hidden. -->
<div id="baseItem" class="item clearfix" style="display:none">
	<div class="right">
		<a id="removeLink" class="removeLink" href="">[ <@s.text name='manage.metadata.removethis'/> <@s.text name='manage.metadata.taxcoverage.item'/> ]</a>
	</div>

	<@text i18nkey="eml.taxonomicCoverages.description" help="i18n" name="description" />

	<!-- Taxon list-->
	<div class="addNew"><a id="taxonsLink" class="show-taxonList" href="" ><@s.text name='manage.metadata.taxcoverage.addSeveralTaxa' help="i18n" /></a></div>
	<div id="list" class="half clearfix" style="display:none">
		<@text i18nkey="eml.taxonomicCoverages.taxonList" help="i18n" name="taxon-list" value="" />
		<div class="buttons taxon-list">
			<@s.submit cssClass="button" name="add-button" key="button.add"/>
		</div>
	</div>
	<div id="subItems"></div>
	<div class="addNew"><a id="plus-subItem" href="" ><@s.text name='manage.metadata.addnew' /> <@s.text name='manage.metadata.taxcoverage.taxon.item' /></a></div>
</div>
<div id="subItem-9999" class="sub-item grid_17 suffix_1 clearfix" style="display:none">
	<div class="third">
		<@input i18nkey="eml.taxonomicCoverages.taxonKeyword.scientificName" help="i18n" name="scientificName" requiredField=true />
		<@input i18nkey="eml.taxonomicCoverages.taxonKeyword.commonName" help="i18n" name="commonName" />
		<@select i18nkey="eml.taxonomicCoverages.taxonKeyword.rank" help="i18n" name="rank" options=ranks />
		<img id="trash" class="trash-icon" src="${baseURL}/images/trash-m.png">
	</div>
</div>

<#include "/WEB-INF/pages/inc/footer.ftl">
</#escape>
