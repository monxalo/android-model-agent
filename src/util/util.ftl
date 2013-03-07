<#macro getRelations>
<#assign hasBelongMany = ""
i=0
k=0
relationTablesDeclaration=""
relationJoinDeclaration=""
relationTablesDefinition=""
matcherURI=""
uriCode=""
query="">
<#list doc.root.entity as p>
	<#if p.@hasAndBelongsToMany[0]??>
		<#assign hasBelongMany="${hasBelongMany}${p.@name}:${p.@hasAndBelongsToMany},">
	</#if>
</#list>
<#if hasBelongMany !="">
<#assign hasBelongMany = hasBelongMany?substring(0,hasBelongMany?length-1)
reflist = hasBelongMany?split(",")>
<#list reflist as l>
	<#assign ref=l?split(":")
	from =ref[0]
	to = ref[1]
	>
	<#list reflist as l2>
		<#if i < k >
			<#assign ref2=l2?split(":")>
			<#if ref2[0]==to>
				<#if ref2[1]==from>
					<#assign relationTablesDeclaration ="${relationTablesDeclaration}protected static final String ${from?upper_case}_${to?upper_case} = \"${from?lower_case}_${to?lower_case}\";,">
					<#assign relationJoinDeclaration>
${relationJoinDeclaration}protected static final String ${from?upper_case}_JOIN_${from?upper_case}_${to?upper_case} = ${from?upper_case} 
				+ " INNER JOIN "+${from?upper_case}_${to?upper_case}+" ON _id = ${from?substring(0,from?length-1)}_id";,protected static final String ${to?upper_case}_JOIN_${from?upper_case}_${to?upper_case} = ${to?upper_case} 
				+ " INNER JOIN "+${from?upper_case}_${to?upper_case}+" ON _id = ${to?substring(0,to?length-1)}_id";,</#assign>
					<#assign relationTablesDefinition>
${relationTablesDefinition}db.execSQL("+CREATE TABLE " + Tables.${from?upper_case}_${to?upper_case} + " ("
			+ BaseColumns._ID + " INTEGER PRIMARY KEY AUTOINCREMENT,"
			+ "${from?substring(0,from?length-1)}_id INTEGER NOT NULL REFERENCES "+Tables.${to?upper_case}+"("+BaseColumns._ID+"),"
			+ "${to?substring(0,to?length-1)}_id INTEGER NOT NULL REFERENCES "+Tables.${from?upper_case}+"("+BaseColumns._ID+")"
			+ ")");:</#assign>
					<#assign uriCode="${uriCode}${from?upper_case}_ID_${to?upper_case}:${to?upper_case}_ID_${from?upper_case}:" >
					<#assign matcherURI>
${matcherURI}matcher.addURI(authority, "${from}/#/${to}", ${from?upper_case}_ID_${to?upper_case});:matcher.addURI(authority, "${to}/#/${from}", ${to?upper_case}_ID_${from?upper_case});</#assign>
					<#assign query>
${query}case ${from?upper_case}_ID_${to?upper_case}: {
				final String ${to?substring(0,to?length-1)}Id = Types.get${to?capitalize}Id(uri);
				return builder.table(Table.${from?upper_case}_JOIN_${from?upper_case}_${to?upper_case}).where("_id=?", eventId);
			}::case ${to?upper_case}_ID_${from?upper_case}: {
				final String ${from?substring(0,from?length-1)}Id = Types.get${from?capitalize}Id(uri);
				return builder.table(Table.${from?upper_case}_JOIN_${from?upper_case}_${to?upper_case}).where("_id=?", ${from?substring(0,from?length-1)}Id);
			}::</#assign>
				</#if>
			</#if>
		</#if>
		<#assign k=k+1>
	</#list>
	<#assign k=0>
	<#assign i=i+1>
</#list>
</#if>
<#if relationTablesDeclaration!= "">
<#assign relationTablesDeclaration = relationTablesDeclaration?substring(0,relationTablesDeclaration?length-1)?split(",") >
<#else>
<#assign relationTablesDeclaration = relationTablesDeclaration?split(",") >
</#if>
<#if relationJoinDeclaration!= "">
<#assign relationJoinDeclaration = relationJoinDeclaration?substring(0,relationJoinDeclaration?length-1)?split(",") >
<#else>
<#assign relationJoinDeclaration = relationJoinDeclaration?split(",") >
</#if>
<#if relationTablesDefinition!="">
<#assign relationTablesDefinition = relationTablesDefinition?substring(0,relationTablesDefinition?length-1)?split(":") >
<#else>
<#assign relationTablesDefinition = relationTablesDefinition?split(":") >
</#if>
<#if uriCode !="">
<#assign uriCode = uriCode?substring(0,uriCode?length-1)?split(":") >
<#else>
<#assign uriCode = uriCode?split(":") >
</#if>
<#if matcherURI!="">
<#assign matcherURI = matcherURI?substring(0,matcherURI?length-1)?split(":") >
<#else>
<#assign matcherURI = matcherURI?split(":") >
</#if>
<#if query!="">
<#assign query = query?substring(0,query?length-2)?split("::") >
<#else>
<#assign query = query?split("::") >
</#if>
</#macro>

<#function getClassName name>
<#return name?replace("_"," ")?capitalize?replace(" ","")>
</#function>
