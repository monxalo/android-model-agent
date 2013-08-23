<#include "util/util.ftl">
<@getRelations/>
<#assign namespace = doc.root.@namespace
prefix = doc.root.@prefix?capitalize>
package ${namespace}.provider;

<#list doc.root.entity as p>
import ${namespace}.provider.${prefix}Contract.${p.@name?capitalize};
</#list>

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.provider.BaseColumns;

public class ${prefix}Database extends SQLiteOpenHelper {

    private static final int VER_LAUNCH = 22;
	private static final int DATABASE_VERSION = VER_LAUNCH;
	
	public ${prefix}Database(Context context) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
	}
	
	static class Tables {
	<#list doc.root.entity as p>
		protected static final String ${p.@name?upper_case} = "${p.@name?lower_case}";
	</#list>
	<#list relationTablesDeclaration as p>
		${p}
	</#list>
	<#list doc.root.entity as p>
		<#list p.* as field>
		<#if field.@ref[0]??><#assign result = field.@ref?split(".")>
		protected static final String ${p.@name?upper_case}_JOIN_${result[0]?upper_case} = ${p.@name?upper_case}
				+ " INNER JOIN "+${result[0]?upper_case} + " ON "+${p.@name?capitalize}.${field.@name?upper_case}+"="+${result[0]?capitalize}.${result[1]?upper_case};
			</#if>
		</#list>
	</#list>
	<#list relationJoinDeclaration as p>
		${p}
	</#list>
	}
	
	private static final String TAG = "${prefix}Database";
	private static final String DATABASE_NAME = "${prefix?lower_case}.db";
	
	@Override
	public void onCreate(SQLiteDatabase db) {
		 <#list doc.root.entity as p>
		 <#assign entity = p.@name?upper_case >
		 db.execSQL("CREATE TABLE " + Tables.${entity} + " ("
		    <#if p.@generateIds?string == "true">
		 	+ BaseColumns._ID + " INTEGER PRIMARY KEY AUTOINCREMENT,"
		    </#if>
		 	<#list p.* as field>
		 	+ ${getClassName(entity)}.${field.@name?upper_case} + " <#if field.@type?string == "string">TEXT<#elseif field.@type?string == "date">INTEGER<#elseif field.@type == "int">INTEGER</#if><#if field.@isNull == "true"><#else> NOT NULL<#if field_has_next></#if></#if><#if
		 	 field.@ref[0]??> REFERENCES<#assign result = field.@ref?split(".")> "+Tables.${result[0]?upper_case}+"("+BaseColumns.${result[1]?upper_case}+")</#if><#if field_has_next>,</#if>"
		 	</#list>
		 	+ ")");
		 </#list>
		 <#list relationTablesDefinition as t>
		 ${t}
		 </#list>
	}
	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
	
	}
}
