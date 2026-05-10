// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

package io.ballerina.lib.data.jsondata.json.schema;

import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.AdditionalPropertiesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.AllOfKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.AnyOfKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.DependentSchemasKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.ElseKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.IfKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.ItemsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.NotKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.OneOfKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.PatternPropertiesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.PrefixItemsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.PropertiesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.PropertyNamesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.ThenKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.content.ContentEncodingKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.content.ContentMediaTypeKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.content.ContentSchemaKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.core.AnchorKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.core.DefsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.core.DynamicAnchorKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.core.DynamicRefKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.core.IdKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.core.RefKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.metadata.CommentKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.metadata.DefaultKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.metadata.DeprecatedKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.metadata.DescriptionKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.metadata.ExamplesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.metadata.ReadOnlyKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.metadata.TitleKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.metadata.WriteOnlyKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.unevaluated.UnevaluatedItemsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.unevaluated.UnevaluatedPropertiesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.ConstKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.ContainsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.DependentRequiredKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.EnumKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.ExclusiveMaximumKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.ExclusiveMinimumKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.FormatKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.MaxItemsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.MaxLengthKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.MaxPropertiesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.MaximumKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.MinItemsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.MinLengthKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.MinPropertiesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.MinimumKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.MultipleOfKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.PatternKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.RequiredKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.TypeKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.UniqueItemsKeyword;
import io.ballerina.lib.data.jsondata.utils.DiagnosticLog;
import io.ballerina.lib.data.jsondata.utils.SchemaParserUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BRegexpValue;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.langlib.regexp.FromString;

import java.net.URI;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class SchemaJsonParser {
    private final SchemaRegistry registry;
    private final Set<URI> currentCallUris;

    private final Deque<String> lexicalScopeStack = new ArrayDeque<>();

    public SchemaRegistry getRegistry() {
        return registry;
    }

    public SchemaJsonParser(Set<URI> currentCallUris, SchemaRegistry registry) {
        this.currentCallUris = currentCallUris;
        this.registry = registry;
    }

    public Object parse(Object json) {
        if (json == null) {
            return DiagnosticLog.createJsonError(
                    "Invalid JSON Schema: expected object or boolean, got null");
        }
        if (json instanceof BMap<?, ?>) {
            return parseSchema((BMap<BString, Object>) json);
        } else if (json instanceof Boolean) {
            return json;
        } else {
            return DiagnosticLog.createJsonError(
                    "Invalid JSON Schema: expected object or boolean, got " + json.getClass().getSimpleName());
        }
    }

    private Object parseSchema(BMap<BString, Object> json) {
        LinkedHashMap<String, Keyword> keywords = new LinkedHashMap<>();
        boolean scopePushed = false;
        String resolvedId = null;
        URI resolvedIdUri = null;
        String anchorName = null;
        String dynamicAnchorName = null;

        Long minContains = SchemaParserUtils.extractInteger(json, "minContains");
        Long maxContains = SchemaParserUtils.extractInteger(json, "maxContains");

        BString idKey = StringUtils.fromString(IdKeyword.KEYWORD_NAME);
        if (json.containsKey(idKey)) {
            Object idValue = json.get(idKey);
            if (!(idValue instanceof BString)) {
                return DiagnosticLog.createJsonError("Invalid value for '$id': expected string");
            }
            String idStr = ((BString) idValue).getValue();
            String base = lexicalScopeStack.isEmpty() ? registry.getMockRootUri() : lexicalScopeStack.peek();
            resolvedId = SchemaRegistry.resolveURI(base, idStr);
            resolvedIdUri = URI.create(resolvedId);

            if (registry.containsKey(resolvedIdUri)) {
                currentCallUris.add(resolvedIdUri);
                return registry.get(resolvedIdUri);
            }

            lexicalScopeStack.push(resolvedId);
            scopePushed = true;
            keywords.put(IdKeyword.KEYWORD_NAME, new IdKeyword(resolvedIdUri));
        }

        BString anchorKey = StringUtils.fromString(AnchorKeyword.KEYWORD_NAME);
        if (json.containsKey(anchorKey)) {
            Object anchorValue = json.get(anchorKey);
            if (!(anchorValue instanceof BString)) {
                return DiagnosticLog.createJsonError("Invalid value for '$anchor': expected string");
            }
            anchorName = ((BString) anchorValue).getValue();
            if (!SchemaParserUtils.isValidAnchorName(anchorName)) {
                return DiagnosticLog.createJsonError(
                        "Invalid $anchor value: must match pattern " + SchemaParserUtils.VALID_ANCHOR_REGEX);
            }
            keywords.put(AnchorKeyword.KEYWORD_NAME, new AnchorKeyword(anchorValue));
        }

        BString dynamicAnchorKey = StringUtils.fromString(DynamicAnchorKeyword.KEYWORD_NAME);
        if (json.containsKey(dynamicAnchorKey)) {
            Object dynamicAnchorValue = json.get(dynamicAnchorKey);
            if (!(dynamicAnchorValue instanceof BString)) {
                return DiagnosticLog.createJsonError("Invalid value for '$dynamicAnchor': expected string");
            }
            dynamicAnchorName = ((BString) dynamicAnchorValue).getValue();
            if (!SchemaParserUtils.isValidAnchorName(dynamicAnchorName)) {
                return DiagnosticLog.createJsonError(
                        "Invalid $dynamicAnchor value: must match pattern " + SchemaParserUtils.VALID_ANCHOR_REGEX);
            }
            keywords.put(DynamicAnchorKeyword.KEYWORD_NAME, new DynamicAnchorKeyword(dynamicAnchorName));
        }

        try {
            for (BString bKey : json.getKeys()) {
                String key = bKey.getValue();
                Object value = json.get(bKey);

                Object err = extractKeyword(key, value, keywords, minContains, maxContains);
                if (err instanceof BError) {
                    return err;
                }
            }

            Schema schema = new Schema(keywords);
            if (lexicalScopeStack.isEmpty() && resolvedId == null) {
                URI mockUri = URI.create(registry.getMockRootUri());
                registry.put(mockUri, schema);
                currentCallUris.add(mockUri);
            }

            if (resolvedIdUri != null) {
                if (registry.containsKey(resolvedIdUri)) {
                    return DiagnosticLog.createJsonError("Duplicate $id: " + resolvedId);
                }
                registry.put(resolvedIdUri, schema);
                currentCallUris.add(resolvedIdUri);
            }

            if (anchorName != null) {
                String currentBase = lexicalScopeStack.isEmpty() ? registry.getMockRootUri() : lexicalScopeStack.peek();
                String anchorUriStr = currentBase + "#" + anchorName;
                URI anchorUri;
                try {
                    anchorUri = URI.create(anchorUriStr);
                } catch (IllegalArgumentException e) {
                    return DiagnosticLog.createJsonError("Invalid $anchor URI: " + anchorUriStr);
                }

                if (registry.containsKey(anchorUri)) {
                    return DiagnosticLog.createJsonError("Duplicate fragment URI: " + anchorUriStr);
                }
                registry.put(anchorUri, schema);
            }

            if (dynamicAnchorName != null) {
                String currentBase = lexicalScopeStack.isEmpty() ? registry.getMockRootUri() : lexicalScopeStack.peek();
                String dynamicAnchorUriStr = currentBase + "#" + dynamicAnchorName;
                URI dynamicAnchorUri;
                try {
                    dynamicAnchorUri = URI.create(dynamicAnchorUriStr);
                } catch (IllegalArgumentException e) {
                    return DiagnosticLog.createJsonError("Invalid $dynamicAnchor URI: " + dynamicAnchorUriStr);
                }

                if (registry.containsKey(dynamicAnchorUri)) {
                    return DiagnosticLog.createJsonError("Duplicate fragment URI: " + dynamicAnchorUriStr);
                }
                registry.put(dynamicAnchorUri, schema);
                registry.registerDynamicAnchor(dynamicAnchorUri);
            }

            return schema;

        } finally {
            if (scopePushed && !lexicalScopeStack.isEmpty()) {
                lexicalScopeStack.pop();
            }
        }
    }

    private Object extractKeyword(String key, Object value,
                                  LinkedHashMap<String, Keyword> keywords,
                                  Long minContains, Long maxContains) {
        Object result = extractApplicatorKeyword(key, value, keywords, minContains, maxContains);
        if (result instanceof BError) {
            return result;
        }

        result = extractValidationKeyword(key, value, keywords);
        if (result instanceof BError) {
            return result;
        }

        result = extractCoreKeyword(key, value, keywords);
        if (result instanceof BError) {
            return result;
        }

        result = extractUnevaluatedKeyword(key, value, keywords);
        if (result instanceof BError) {
            return result;
        }

        result = extractMetadataKeyword(key, value, keywords);
        if (result instanceof BError) {
            return result;
        }

        result = extractContentKeyword(key, value, keywords);
        if (result instanceof BError) {
            return result;
        }

        return null;
    }

    private Object extractApplicatorKeyword(String key, Object value, LinkedHashMap<String, Keyword> keywords,
                                            Long minContains, Long maxContains) {
        switch (key) {
            case PropertiesKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BMap<?, ?>)) {
                    return DiagnosticLog.createJsonError("Invalid value for 'properties' keyword");
                }
                Object parsed = parseSchemaMap((BMap<BString, Object>) value);
                if (parsed instanceof BError) {
                    return parsed;
                }
                keywords.put(PropertiesKeyword.KEYWORD_NAME, new PropertiesKeyword((Map<String, Object>) parsed));
                return null;
            }
            case PatternPropertiesKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BMap<?, ?>)) {
                    return DiagnosticLog.createJsonError("Invalid value for 'patternProperties' keyword");
                }
                Object parsed = parseSchemaMap((BMap<BString, Object>) value);
                if (parsed instanceof BError) {
                    return parsed;
                }
                keywords.put(PatternPropertiesKeyword.KEYWORD_NAME,
                        new PatternPropertiesKeyword((Map<String, Object>) parsed));
                return null;
            }
            case AdditionalPropertiesKeyword.KEYWORD_NAME -> {
                if (value instanceof Boolean) {
                    keywords.put(AdditionalPropertiesKeyword.KEYWORD_NAME,
                            new AdditionalPropertiesKeyword(value));
                    return null;
                }
                if (value instanceof BMap<?, ?>) {
                    Object parsed = parse(value);
                    if (parsed instanceof BError) {
                        return parsed;
                    }
                    keywords.put(AdditionalPropertiesKeyword.KEYWORD_NAME,
                            new AdditionalPropertiesKeyword(parsed));
                    return null;
                }
                return DiagnosticLog.createJsonError("Invalid value for 'additionalProperties' keyword");
            }
            case PropertyNamesKeyword.KEYWORD_NAME -> {
                Object parsed = parse(value);
                if (parsed instanceof BError) {
                    return parsed;
                }
                keywords.put(PropertyNamesKeyword.KEYWORD_NAME, new PropertyNamesKeyword(parsed));
                return null;
            }
            case ItemsKeyword.KEYWORD_NAME -> {
                Object parsed = parse(value);
                if (parsed instanceof BError) {
                    return parsed;
                }
                keywords.put(ItemsKeyword.KEYWORD_NAME, new ItemsKeyword(parsed));
                return null;
            }
            case PrefixItemsKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BArray)) {
                    return DiagnosticLog.createJsonError("Invalid value for 'prefixItems' keyword");
                }
                Object parsed = parseSchemaArray((BArray) value);
                if (parsed instanceof BError) {
                    return parsed;
                }
                keywords.put(PrefixItemsKeyword.KEYWORD_NAME, new PrefixItemsKeyword((List<Object>) parsed));
                return null;
            }
            case ContainsKeyword.KEYWORD_NAME -> {
                Object parsed = parse(value);
                if (parsed instanceof BError) {
                    return parsed;
                }
                keywords.put(ContainsKeyword.KEYWORD_NAME, new ContainsKeyword(minContains, maxContains, parsed));
                return null;
            }
            case AllOfKeyword.KEYWORD_NAME -> {
                return handleSchemaArrayKeyword(value, keywords, AllOfKeyword.KEYWORD_NAME, "allOf");
            }
            case AnyOfKeyword.KEYWORD_NAME -> {
                return handleSchemaArrayKeyword(value, keywords, AnyOfKeyword.KEYWORD_NAME, "anyOf");
            }
            case OneOfKeyword.KEYWORD_NAME -> {
                return handleSchemaArrayKeyword(value, keywords, OneOfKeyword.KEYWORD_NAME, "oneOf");
            }
            case NotKeyword.KEYWORD_NAME -> {
                return handleSingleSchemaKeyword(value, keywords, NotKeyword.KEYWORD_NAME);
            }
            case IfKeyword.KEYWORD_NAME -> {
                return handleSingleSchemaKeyword(value, keywords, IfKeyword.KEYWORD_NAME);
            }
            case ThenKeyword.KEYWORD_NAME -> {
                return handleSingleSchemaKeyword(value, keywords, ThenKeyword.KEYWORD_NAME);
            }
            case ElseKeyword.KEYWORD_NAME -> {
                return handleSingleSchemaKeyword(value, keywords, ElseKeyword.KEYWORD_NAME);
            }
            case DependentSchemasKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BMap<?, ?>)) {
                    return DiagnosticLog.createJsonError("Invalid value for 'dependentSchemas' keyword");
                }
                Object parsed = parseSchemaMap((BMap<BString, Object>) value);
                if (parsed instanceof BError) {
                    return parsed;
                }
                keywords.put(DependentSchemasKeyword.KEYWORD_NAME,
                        new DependentSchemasKeyword((Map<String, Object>) parsed));
                return null;
            }
            default -> {
                return null;
            }
        }
    }

    private Object extractValidationKeyword(String key, Object value, LinkedHashMap<String, Keyword> keywords) {
        switch (key) {
            case TypeKeyword.KEYWORD_NAME -> {
                if (value instanceof BString typeName) {
                    keywords.put(TypeKeyword.KEYWORD_NAME, new TypeKeyword(typeName.getValue()));
                    return null;
                }
                if (value instanceof BArray typeArray) {
                    Set<String> typeNames = new HashSet<>();
                    for (long i = 0; i < typeArray.size(); i++) {
                        Object el = typeArray.get(i);
                        if (el instanceof BString s) {
                            typeNames.add(s.getValue());
                        } else {
                            return DiagnosticLog.createJsonError("Invalid value for 'type' keyword");
                        }
                    }
                    if (!typeNames.isEmpty()) {
                        keywords.put(TypeKeyword.KEYWORD_NAME, new TypeKeyword(typeNames));
                    }
                    return null;
                }
                return DiagnosticLog.createJsonError("Invalid value for 'type' keyword");
            }
            case RequiredKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BArray arr)) {
                    return DiagnosticLog.createJsonError("Invalid value for 'required' keyword");
                }
                ArrayList<String> required = new ArrayList<>();
                for (long i = 0; i < arr.size(); i++) {
                    Object el = arr.get(i);
                    if (el instanceof BString s) {
                        required.add(s.getValue());
                    } else {
                        return DiagnosticLog.createJsonError("Invalid value for 'required' keyword");
                    }
                }
                keywords.put(RequiredKeyword.KEYWORD_NAME, new RequiredKeyword(required));
                return null;
            }
            case DependentRequiredKeyword.KEYWORD_NAME -> {
                Object depRequired = extractDependentRequired(value);
                if (depRequired instanceof BError) {
                    return depRequired;
                }
                keywords.put(DependentRequiredKeyword.KEYWORD_NAME,
                        new DependentRequiredKeyword((Map<String, List<String>>) depRequired));
                return null;
            }
            case PatternKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BString pv)) {
                    return DiagnosticLog.createJsonError("Invalid value for 'pattern' keyword");
                }
                Object regex = FromString.fromString(pv);
                if (regex instanceof BRegexpValue regexVal) {
                    keywords.put(PatternKeyword.KEYWORD_NAME, new PatternKeyword(regexVal));
                    return null;
                }
                return DiagnosticLog.createJsonError("Invalid regular expression in 'pattern' keyword: " + pv);
            }
            case MinLengthKeyword.KEYWORD_NAME -> {
                return handleIntegerKeyword(value, keywords, MinLengthKeyword.KEYWORD_NAME, "minLength");
            }
            case MaxLengthKeyword.KEYWORD_NAME -> {
                return handleIntegerKeyword(value, keywords, MaxLengthKeyword.KEYWORD_NAME, "maxLength");
            }
            case FormatKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BString fv)) {
                    return DiagnosticLog.createJsonError("Invalid value for 'format' keyword");
                }
                keywords.put(FormatKeyword.KEYWORD_NAME, new FormatKeyword(fv.getValue()));
                return null;
            }
            case MinimumKeyword.KEYWORD_NAME -> {
                return handleNumberKeyword(value, keywords, MinimumKeyword.KEYWORD_NAME, "minimum");
            }
            case MaximumKeyword.KEYWORD_NAME -> {
                return handleNumberKeyword(value, keywords, MaximumKeyword.KEYWORD_NAME, "maximum");
            }
            case ExclusiveMinimumKeyword.KEYWORD_NAME -> {
                return handleNumberKeyword(value, keywords, ExclusiveMinimumKeyword.KEYWORD_NAME,
                        "exclusiveMinimum");
            }
            case ExclusiveMaximumKeyword.KEYWORD_NAME -> {
                return handleNumberKeyword(value, keywords, ExclusiveMaximumKeyword.KEYWORD_NAME,
                        "exclusiveMaximum");
            }
            case MultipleOfKeyword.KEYWORD_NAME -> {
                return handleNumberKeyword(value, keywords, MultipleOfKeyword.KEYWORD_NAME, "multipleOf");
            }
            case MinItemsKeyword.KEYWORD_NAME -> {
                return handleIntegerKeyword(value, keywords, MinItemsKeyword.KEYWORD_NAME, "minItems");
            }
            case MaxItemsKeyword.KEYWORD_NAME -> {
                return handleIntegerKeyword(value, keywords, MaxItemsKeyword.KEYWORD_NAME, "maxItems");
            }
            case UniqueItemsKeyword.KEYWORD_NAME -> {
                if (!(value instanceof Boolean boolValue)) {
                    return DiagnosticLog.createJsonError("Invalid value for 'uniqueItems' keyword");
                }
                keywords.put(UniqueItemsKeyword.KEYWORD_NAME, new UniqueItemsKeyword(boolValue));
                return null;
            }
            case MinPropertiesKeyword.KEYWORD_NAME -> {
                return handleIntegerKeyword(value, keywords, MinPropertiesKeyword.KEYWORD_NAME, "minProperties");
            }
            case MaxPropertiesKeyword.KEYWORD_NAME -> {
                return handleIntegerKeyword(value, keywords, MaxPropertiesKeyword.KEYWORD_NAME, "maxProperties");
            }
            case EnumKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BArray arr)) {
                    return DiagnosticLog.createJsonError("Invalid value for 'enum' keyword");
                }
                Set<Object> enumValues = new HashSet<>();
                for (long i = 0; i < arr.size(); i++) {
                    enumValues.add(arr.get(i));
                }
                keywords.put(EnumKeyword.KEYWORD_NAME, new EnumKeyword(enumValues));
                return null;
            }
            case ConstKeyword.KEYWORD_NAME -> {
                keywords.put(ConstKeyword.KEYWORD_NAME, new ConstKeyword(value));
                return null;
            }
            default -> {
                return null;
            }
        }
    }

    private Object extractCoreKeyword(String key, Object value, LinkedHashMap<String, Keyword> keywords) {
        switch (key) {
            case RefKeyword.KEYWORD_NAME -> {
                Object resolvedUri = resolveKeywordUri(value, "$ref");
                if (resolvedUri instanceof BError) {
                    return resolvedUri;
                }
                keywords.put(RefKeyword.KEYWORD_NAME, new RefKeyword((URI) resolvedUri));
                return null;
            }
            case DynamicRefKeyword.KEYWORD_NAME -> {
                Object resolvedUri = resolveKeywordUri(value, "$dynamicRef");
                if (resolvedUri instanceof BError) {
                    return resolvedUri;
                }
                URI dynamicRefUri = (URI) resolvedUri;
                String fragment = dynamicRefUri.getFragment();
                String anchorNameForRef = (fragment != null && !fragment.startsWith("/")) ? fragment : null;
                keywords.put(DynamicRefKeyword.KEYWORD_NAME,
                        new DynamicRefKeyword(dynamicRefUri, anchorNameForRef));
                return null;
            }
            case DefsKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BMap<?, ?>)) {
                    return DiagnosticLog.createJsonError("Invalid value for '$defs': expected object");
                }
                BMap<BString, Object> defs = (BMap<BString, Object>) value;
                Map<String, Object> defsMap = new LinkedHashMap<>();
                for (BString defName : defs.getKeys()) {
                    Object defParsed = parse(defs.get(defName));
                    if (defParsed instanceof BError) {
                        return defParsed;
                    }
                    defsMap.put(defName.getValue(), defParsed);
                }
                keywords.put(DefsKeyword.KEYWORD_NAME, new DefsKeyword(defsMap));
                return null;
            }
            default -> {
                return null;
            }
        }
    }

    private Object extractUnevaluatedKeyword(String key, Object value, LinkedHashMap<String, Keyword> keywords) {
        switch (key) {
            case UnevaluatedItemsKeyword.KEYWORD_NAME -> {
                return handleSingleSchemaKeyword(value, keywords, UnevaluatedItemsKeyword.KEYWORD_NAME);
            }
            case UnevaluatedPropertiesKeyword.KEYWORD_NAME -> {
                return handleSingleSchemaKeyword(value, keywords, UnevaluatedPropertiesKeyword.KEYWORD_NAME);
            }
            default -> {
                return null;
            }
        }
    }

    private Object extractMetadataKeyword(String key, Object value, LinkedHashMap<String, Keyword> keywords) {
        switch (key) {
            case TitleKeyword.KEYWORD_NAME -> {
                if (value instanceof BString title) {
                    keywords.put(TitleKeyword.KEYWORD_NAME, new TitleKeyword(title.getValue()));
                }
                return null;
            }
            case DescriptionKeyword.KEYWORD_NAME -> {
                if (value instanceof BString description) {
                    keywords.put(DescriptionKeyword.KEYWORD_NAME,
                            new DescriptionKeyword(description.getValue()));
                }
                return null;
            }
            case DefaultKeyword.KEYWORD_NAME -> {
                keywords.put(DefaultKeyword.KEYWORD_NAME, new DefaultKeyword(value));
                return null;
            }
            case ExamplesKeyword.KEYWORD_NAME -> {
                if (value instanceof BArray) {
                    keywords.put(ExamplesKeyword.KEYWORD_NAME, new ExamplesKeyword(value));
                }
                return null;
            }
            case ReadOnlyKeyword.KEYWORD_NAME -> {
                if (value instanceof Boolean readOnly) {
                    keywords.put(ReadOnlyKeyword.KEYWORD_NAME, new ReadOnlyKeyword(readOnly));
                }
                return null;
            }
            case WriteOnlyKeyword.KEYWORD_NAME -> {
                if (value instanceof Boolean writeOnly) {
                    keywords.put(WriteOnlyKeyword.KEYWORD_NAME, new WriteOnlyKeyword(writeOnly));
                }
                return null;
            }
            case DeprecatedKeyword.KEYWORD_NAME -> {
                if (value instanceof Boolean deprecated) {
                    keywords.put(DeprecatedKeyword.KEYWORD_NAME, new DeprecatedKeyword(deprecated));
                }
                return null;
            }
            case CommentKeyword.KEYWORD_NAME -> {
                if (value instanceof BString) {
                    keywords.put(CommentKeyword.KEYWORD_NAME, new CommentKeyword(((BString) value).getValue()));
                }
                return null;
            }
            default -> {
                return null;
            }
        }
    }

    private Object extractContentKeyword(String key, Object value, LinkedHashMap<String, Keyword> keywords) {
        switch (key) {
            case ContentEncodingKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BString encoding)) {
                    return DiagnosticLog.createJsonError(
                            "Invalid value for 'contentEncoding' keyword: expected string");
                }
                keywords.put(ContentEncodingKeyword.KEYWORD_NAME, new ContentEncodingKeyword(encoding.getValue()));
                return null;
            }
            case ContentMediaTypeKeyword.KEYWORD_NAME -> {
                if (!(value instanceof BString mediaType)) {
                    return DiagnosticLog.createJsonError(
                            "Invalid value for 'contentMediaType' keyword: expected string");
                }
                keywords.put(ContentMediaTypeKeyword.KEYWORD_NAME,
                        new ContentMediaTypeKeyword(mediaType.getValue()));
                return null;
            }
            case ContentSchemaKeyword.KEYWORD_NAME -> {
                Object parsed = parse(value);
                if (parsed instanceof BError) {
                    return parsed;
                }
                if (!(parsed instanceof Schema || parsed instanceof Boolean)) {
                    return DiagnosticLog.createJsonError(
                            "Invalid value for 'contentSchema' keyword: expected valid schema");
                }
                keywords.put(ContentSchemaKeyword.KEYWORD_NAME, new ContentSchemaKeyword(parsed));
                return null;
            }
            default -> {
                return null;
            }
        }
    }

    private Object handleSchemaArrayKeyword(Object value, LinkedHashMap<String, Keyword> keywords,
                                            String keywordName, String displayName) {
        if (!(value instanceof BArray)) {
            return DiagnosticLog.createJsonError("Invalid value for '" + displayName + "' keyword");
        }
        Object parsed = parseSchemaArray((BArray) value);
        if (parsed instanceof BError) {
            return parsed;
        }
        List<Object> parsedList = (List<Object>) parsed;
        switch (keywordName) {
            case AllOfKeyword.KEYWORD_NAME -> keywords.put(keywordName, new AllOfKeyword(parsedList));
            case AnyOfKeyword.KEYWORD_NAME -> keywords.put(keywordName, new AnyOfKeyword(parsedList));
            case OneOfKeyword.KEYWORD_NAME -> keywords.put(keywordName, new OneOfKeyword(parsedList));
            default -> {
                return null;
            }
        }
        return null;
    }

    private Object handleSingleSchemaKeyword(Object value, LinkedHashMap<String, Keyword> keywords,
                                             String keywordName) {
        Object parsed = parse(value);
        if (parsed instanceof BError) {
            return parsed;
        }
        switch (keywordName) {
            case NotKeyword.KEYWORD_NAME -> keywords.put(keywordName, new NotKeyword(parsed));
            case IfKeyword.KEYWORD_NAME -> keywords.put(keywordName, new IfKeyword(parsed));
            case ThenKeyword.KEYWORD_NAME -> keywords.put(keywordName, new ThenKeyword(parsed));
            case ElseKeyword.KEYWORD_NAME -> keywords.put(keywordName, new ElseKeyword(parsed));
            case UnevaluatedItemsKeyword.KEYWORD_NAME -> keywords.put(keywordName, new UnevaluatedItemsKeyword(parsed));
            case UnevaluatedPropertiesKeyword.KEYWORD_NAME ->
                    keywords.put(keywordName, new UnevaluatedPropertiesKeyword(parsed));
            default -> {
                return null;
            }
        }
        return null;
    }

    private Object handleIntegerKeyword(Object value, LinkedHashMap<String, Keyword> keywords,
                                        String keywordName, String displayName) {
        Long v = SchemaParserUtils.toInteger(value);
        if (v == null) {
            return DiagnosticLog.createJsonError("Invalid value for '" + displayName + "' keyword");
        }
        switch (keywordName) {
            case MinLengthKeyword.KEYWORD_NAME -> keywords.put(keywordName, new MinLengthKeyword(v));
            case MaxLengthKeyword.KEYWORD_NAME -> keywords.put(keywordName, new MaxLengthKeyword(v));
            case MinItemsKeyword.KEYWORD_NAME -> keywords.put(keywordName, new MinItemsKeyword(v));
            case MaxItemsKeyword.KEYWORD_NAME -> keywords.put(keywordName, new MaxItemsKeyword(v));
            case MinPropertiesKeyword.KEYWORD_NAME -> keywords.put(keywordName, new MinPropertiesKeyword(v));
            case MaxPropertiesKeyword.KEYWORD_NAME -> keywords.put(keywordName, new MaxPropertiesKeyword(v));
            default -> {
                return null;
            }
        }
        return null;
    }

    private Object handleNumberKeyword(Object value, LinkedHashMap<String, Keyword> keywords,
                                       String keywordName, String displayName) {
        Double v = SchemaParserUtils.toNumber(value);
        if (v == null) {
            return DiagnosticLog.createJsonError("Invalid value for '" + displayName + "' keyword");
        }
        switch (keywordName) {
            case MinimumKeyword.KEYWORD_NAME -> keywords.put(keywordName, new MinimumKeyword(v));
            case MaximumKeyword.KEYWORD_NAME -> keywords.put(keywordName, new MaximumKeyword(v));
            case ExclusiveMinimumKeyword.KEYWORD_NAME -> keywords.put(keywordName, new ExclusiveMinimumKeyword(v));
            case ExclusiveMaximumKeyword.KEYWORD_NAME -> keywords.put(keywordName, new ExclusiveMaximumKeyword(v));
            case MultipleOfKeyword.KEYWORD_NAME -> keywords.put(keywordName, new MultipleOfKeyword(v));
            default -> {
                return null;
            }
        }
        return null;
    }

    private Object resolveKeywordUri(Object value, String keywordName) {
        if (!(value instanceof BString refVal)) {
            return DiagnosticLog.createJsonError("Invalid value for '" + keywordName + "' keyword");
        }
        String base = lexicalScopeStack.isEmpty() ? registry.getMockRootUri() : lexicalScopeStack.peek();
        String resolved = SchemaRegistry.resolveURI(base, refVal.getValue());
        try {
            return URI.create(resolved);
        } catch (IllegalArgumentException e) {
            return DiagnosticLog.createJsonError("Invalid URI in '" + keywordName + "': " + resolved);
        }
    }

    private Object extractDependentRequired(Object value) {
        if (!(value instanceof BMap<?, ?>)) {
            return DiagnosticLog.createJsonError("Invalid value for 'dependentRequired' keyword");
        }
        BMap<BString, Object> depMap = (BMap<BString, Object>) value;
        Map<String, List<String>> depRequired = new LinkedHashMap<>();
        for (BString depKey : depMap.getKeys()) {
            Object depVal = depMap.get(depKey);
            List<String> fields = new ArrayList<>();
            if (depVal instanceof BString s) {
                fields.add(s.getValue());
            } else if (depVal instanceof BArray arr) {
                for (long i = 0; i < arr.size(); i++) {
                    Object el = arr.get(i);
                    if (el instanceof BString s) {
                        fields.add(s.getValue());
                    } else {
                        return DiagnosticLog.createJsonError(
                                "Invalid value for 'dependentRequired' keyword");
                    }
                }
            } else {
                return DiagnosticLog.createJsonError("Invalid value for 'dependentRequired' keyword");
            }
            depRequired.put(depKey.getValue(), fields);
        }
        return depRequired;
    }

    private Object parseSchemaMap(BMap<BString, Object> schemaMap) {
        Map<String, Object> result = new LinkedHashMap<>();
        for (BString key : schemaMap.getKeys()) {
            Object parsed = parse(schemaMap.get(key));
            if (parsed instanceof BError) {
                return parsed;
            }
            result.put(key.getValue(), parsed);
        }
        return result;
    }

    private Object parseSchemaArray(BArray schemas) {
        List<Object> result = new ArrayList<>();
        for (long i = 0; i < schemas.size(); i++) {
            Object parsed = parse(schemas.get(i));
            if (parsed instanceof BError) {
                return parsed;
            }
            result.add(parsed);
        }
        return result;
    }
}
