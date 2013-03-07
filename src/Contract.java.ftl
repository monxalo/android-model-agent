<#include "util/util.ftl">
<#assign namespace = doc.root.@namespace>
<#assign prefix = doc.root.@prefix>
package ${namespace}.provider;

import android.net.Uri;
import android.provider.BaseColumns;

public class ${doc.root.@prefix}Contract {
	public static final String CONTENT_AUTHORITY = "${namespace}";
	private static final Uri BASE_CONTENT_URI = Uri.parse("content://"
			+ CONTENT_AUTHORITY);

	<#list doc.root.entity as p>				
	private static final String PATH_${p.@name?upper_case} = "${p.@name?lower_case}";	
	</#list>

	<#list doc.root.entity as p>
	public static class ${getClassName(p.@name)} implements BaseColumns {
		public static final Uri CONTENT_URI = BASE_CONTENT_URI.buildUpon()
				.appendPath(PATH_${p.@name?upper_case}).build();
		
		public static final String CONTENT_TYPE = "vnd.android.cursor.dir/vnd.${prefix?lower_case}.${p.@name?lower_case}";
		public static final String CONTENT_ITEM_TYPE = "vnd.android.cursor.item/vnd.${prefix?lower_case}.${p.@name?lower_case}";
		<#list p.* as field>
		public static final String ${field.@name?upper_case} = "${field.@name?lower_case}";
		</#list>
		
		<#assign singular = p.@name?lower_case?substring(0,p.@name?length-1) >
		public static Uri build${singular?capitalize}Uri(String ${singular}Id) {
			return CONTENT_URI.buildUpon().appendPath(${singular}Id).build();
		}
		
		public static String get${singular?capitalize}Id(Uri uri) {
			return uri.getPathSegments().get(1);
		}
	}
	
	</#list>
}
