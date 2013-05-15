<#include "util/util.ftl">
<@getRelations/>
<#assign namespace = doc.root.@namespace>
<#assign prefix = doc.root.@prefix?capitalize>
package ${namespace}.provider;

import java.util.ArrayList;

<#list doc.root.entity as p>
import ${namespace}.provider.${doc.root.@prefix}Contract.${getClassName(p.@name)};
</#list>
import ${namespace}.provider.${doc.root.@prefix}Database.Tables;

import android.content.ContentProvider;
import android.content.ContentProviderOperation;
import android.content.ContentProviderResult;
import android.content.ContentValues;
import android.content.Context;
import android.content.OperationApplicationException; 
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.net.Uri;

public class ${doc.root.@prefix}Provider extends ContentProvider {
	private static final String TAG = "${doc.root.@prefix}Provider";
	private static final boolean LOGV = false;   
	
	private ${doc.root.@prefix}Database mOpenHelper;
	
	private static final UriMatcher sUriMatcher = buildUriMatcher();
	
	<#assign intValue = 100 />
	<#list doc.root.entity as p>
	private static final int ${p.@name?upper_case} = ${intValue};
	private static final int ${p.@name?upper_case}_ID = ${intValue+1};
		<#list p.* as field>
			<#if field.@ref[0]??><#assign result = field.@ref?split(".")>
	private static final int ${getSingular(p)?upper_case}_${result[0]?upper_case} = ${intValue+2};
	private static final int ${getSingular(p)?upper_case}_${result[0]?upper_case}_ID = ${intValue+3};
			</#if>
		</#list>
	<#assign intValue = intValue + 100> 
	</#list>
	<#assign i=0>
	<#list uriCode as p>
		<#if p!="">
	private static final int ${p} = ${intValue+i};
		</#if>
	<#assign i=i+1>
	</#list>
	
	@Override
	public boolean onCreate() {
		final Context context = getContext();
		mOpenHelper = new ${doc.root.@prefix}Database(context);
		return true;
	}
	
	@Override
	public int delete(Uri uri, String selection, String[] selectionArgs) {
		final SQLiteDatabase db = mOpenHelper.getWritableDatabase();
		final SelectionBuilder builder = buildSimpleSelection(uri);
		int count = builder.where(selection, selectionArgs).delete(db);
		if(count>0)
			getContext().getContentResolver().notifyChange(uri, null);
		return count;
	}
	
	@Override
	public String getType(Uri uri) {
		switch (sUriMatcher.match(uri)) {
		<#list doc.root.entity as p>
		case ${p.@name?upper_case}:
			return ${getClassName(p.@name)}.CONTENT_TYPE;
		case ${p.@name?upper_case}_ID:
			return ${getClassName(p.@name)}.CONTENT_ITEM_TYPE;
		</#list>
		default:
			throw new IllegalArgumentException("Unknown URI " + uri);
		}
	}
	
	@Override
	public Uri insert(Uri uri, ContentValues values) {
		final SQLiteDatabase db = mOpenHelper.getWritableDatabase();

		final int match = sUriMatcher.match(uri);
		switch (match) {
			<#list doc.root.entity as p>
			<#assign eventsCap = p.@name?capitalize >
			case ${eventsCap?upper_case}: {
				db.insertOrThrow(Tables.${eventsCap?upper_case}, null, values);
				getContext().getContentResolver().notifyChange(uri, null);
	
				return ${getClassName(eventsCap)}.build${getSingular(p)?capitalize}Uri(values.getAsString(${getClassName(eventsCap)}._ID));
			}
			</#list>
			default: {
				throw new UnsupportedOperationException("Unknown uri: " + uri);
			}
		}
	}
	
	@Override
	public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs,
            String sortOrder) {
		final SQLiteDatabase db = mOpenHelper.getReadableDatabase();
		final int match = sUriMatcher.match(uri);
		
		switch(match) {
			default: {
				final SelectionBuilder builder = buildExpandedSelection(uri,match);
				return builder.where(selection, selectionArgs).query(db, projection, sortOrder);
			}
		}
	} 

	@Override
	public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
		final SQLiteDatabase db = mOpenHelper.getWritableDatabase();
		final SelectionBuilder builder = buildSimpleSelection(uri);
		int count = builder.where(selection, selectionArgs).update(db, values);
		if(count>0)
			getContext().getContentResolver().notifyChange(uri, null);
		return count;
	}
	
	@Override
	public ContentProviderResult[] applyBatch(
			ArrayList<ContentProviderOperation> operations)
			throws OperationApplicationException {
		final SQLiteDatabase db = mOpenHelper.getWritableDatabase();
		db.beginTransaction();
		try {
		    final int numOperations = operations.size();
		    final ContentProviderResult[] results = new ContentProviderResult[numOperations];
		    for (int i = 0; i < numOperations; i++) {
		        results[i] = operations.get(i).apply(this, results, i);
		        db.yieldIfContendedSafely();
		    }
		    db.setTransactionSuccessful();
		    return results;
		} finally {
		    db.endTransaction();
		}
	}
	
	private SelectionBuilder buildSimpleSelection(Uri uri) {
		final SelectionBuilder builder = new SelectionBuilder();
		final int match = sUriMatcher.match(uri);
		switch (match) {
		<#list doc.root.entity as p>
		<#assign fName = p.@name >
		<#assign className = getClassName(getSingular(p)) >
			case ${fName?upper_case}: {
				return builder.table(Tables.${fName?upper_case});
			}
			case ${fName?upper_case}_ID : {
				final String ${className?lower_case}Id = ${getClassName(fName)}.get${className?capitalize}Id(uri);
				return builder.table(Tables.${fName?upper_case}).where(
						${getClassName(fName)}._ID + "=?", ${className?lower_case}Id);
			}
		</#list>
			default :
				throw new UnsupportedOperationException("Unknown uri: " + uri);
		}
	}
	
	private SelectionBuilder buildExpandedSelection(Uri uri, int match) {
		final SelectionBuilder builder = new SelectionBuilder();
		switch (match) {
			<#list doc.root.entity as p>
				<#list p.* as field>
					<#if field.@ref[0]??><#assign result = field.@ref?split(".")>
			case ${p.@name?upper_case}: {
				return builder.table(Table.${p.@name?upper_case}_JOIN_${result[0]?upper_case});
			}
			case ${p.@name?upper_case}_ID: {
				final String ${getSingular(p)}Id = ${p.@name?capitalize}.get${getSingular(p)?capitalize}Id(uri);
				return builder.table(Table.${p.@name?upper_case}_JOIN_${result[0]?upper_case}).where(${p.@name?capitalize}._ID + "=?", ${getSingular(p)}Id);
			}
				</#if>
			</#list>
			</#list>
			<#list query as p>
			${p}
			</#list>
			default :
				throw new UnsupportedOperationException("Unknown uri: " + uri);
		}
	}
	
	private static UriMatcher buildUriMatcher() {
		final UriMatcher matcher = new UriMatcher(UriMatcher.NO_MATCH);
		final String authority = ${doc.root.@prefix}Contract.CONTENT_AUTHORITY;
		<#list doc.root.entity as p>
		matcher.addURI(authority, "${p.@name}", ${p.@name?upper_case});
		matcher.addURI(authority, "${p.@name}/#", ${p.@name?upper_case}_ID);
        </#list>
        <#list matcherURI as p>
        ${p}
        </#list>
        
        return matcher;
	}
}