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
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.ItemsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.NotKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.OneOfKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.PatternPropertiesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.PrefixItemsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.PropertiesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.PropertyNamesKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.content.ContentEncodingKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.content.ContentMediaTypeKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.content.ContentSchemaKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.metadata.CommentKeyword;
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
import io.ballerina.lib.data.jsondata.utils.Constants;
import io.ballerina.lib.data.jsondata.utils.DiagnosticLog;
import io.ballerina.lib.data.jsondata.utils.JsonEqualityUtils;
import io.ballerina.lib.data.jsondata.utils.SchemaParserUtils;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.AnnotatableType;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.FiniteType;
import io.ballerina.runtime.api.types.IntersectionType;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.ReferenceType;
import io.ballerina.runtime.api.types.TupleType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BRegexpValue;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SchemaTypeParser {
    private static final Object NULL_CONST = new Object();

    private final HashMap<String, Object> typeAliasToSchema = new HashMap<>();

    public Object parse(Type type) {
        if (typeAliasToSchema.containsKey(type.getName())) {
            return typeAliasToSchema.get(type.getName());
        }

        if (type.getTag() == TypeTags.TYPE_REFERENCED_TYPE_TAG || type.getTag() == TypeTags.RECORD_TYPE_TAG) {
            typeAliasToSchema.put(type.getName(), new Schema());
        }

        if (type.getTag() == TypeTags.TYPE_REFERENCED_TYPE_TAG) {
            Type immediateReferred = ((ReferenceType) type).getReferredType();
            int immediateTag = immediateReferred.getTag();

            if (immediateTag == TypeTags.TYPE_REFERENCED_TYPE_TAG) {
                return parseTypeReference(type, immediateReferred);
            }
        }

        Type referredType = TypeUtils.getReferredType(type);

        Object schema = switch (referredType.getTag()) {
            case TypeTags.UNION_TAG -> parseUnionType(type);
            case TypeTags.TUPLE_TAG, TypeTags.ARRAY_TAG -> parseArrayType(type);
            case TypeTags.STRING_TAG, TypeTags.INT_TAG, TypeTags.FLOAT_TAG, TypeTags.DECIMAL_TAG,
                    TypeTags.BOOLEAN_TAG, TypeTags.JSON_TAG, TypeTags.NEVER_TAG, TypeTags.NULL_TAG,
                    TypeTags.FINITE_TYPE_TAG, TypeTags.INTERSECTION_TAG -> parseBasicType(type);
            case TypeTags.RECORD_TYPE_TAG -> parseRecordType(type);
            default -> DiagnosticLog.createJsonError("unsupported type: " + referredType);
        };

        if (schema instanceof BError) {
            return schema;
        }

        if (schema instanceof Schema parsedSchema) {
            LinkedHashMap<String, Keyword> keywords = parsedSchema.getKeywords();
            if (keywords.size() == 1 && keywords.containsKey(TypeKeyword.KEYWORD_NAME)) {
                Object typeKeywordValue = keywords.get(TypeKeyword.KEYWORD_NAME).getKeywordValue();
                if (typeKeywordValue instanceof Set<?> typeNames && typeNames.equals(
                        Set.of("string", "number", "boolean", "object", "array", "null"))) {
                    schema = true;
                }
            }
        }

        if (type.getTag() == TypeTags.TYPE_REFERENCED_TYPE_TAG || type.getTag() == TypeTags.RECORD_TYPE_TAG) {
            Schema cachedSchema = (Schema) typeAliasToSchema.get(type.getName());
            if (schema instanceof Schema) {
                cachedSchema.setKeywords(((Schema) schema).getKeywords());
            } else {
                typeAliasToSchema.put(type.getName(), schema);
                return schema;
            }
            return cachedSchema;
        }

        return schema;
    }

    private Object parseTypeReference(Type type, Type immediateReferred) {
        Object innerSchema = parse(immediateReferred);
        if (innerSchema instanceof BError) {
            return innerSchema;
        }

        LinkedHashMap<String, Keyword> keywords = new LinkedHashMap<>();
        Object err = extractKeywordsFromAnnotations(type, keywords);
        if (err instanceof BError) {
            return err;
        }

        Schema cachedSchema = (Schema) typeAliasToSchema.get(type.getName());

        if (keywords.isEmpty()) {
            if (innerSchema instanceof Schema inner) {
                cachedSchema.setKeywords(inner.getKeywords());
                return cachedSchema;
            }
            return innerSchema;
        }

        boolean isAllOf = keywords.containsKey(AllOfKeyword.KEYWORD_NAME);
        boolean isOneOf = keywords.containsKey(OneOfKeyword.KEYWORD_NAME);

        if (isAllOf || isOneOf) {
            List<Object> subschemas = new ArrayList<>();
            subschemas.add(innerSchema);

            if (isAllOf) {
                keywords.put(AllOfKeyword.KEYWORD_NAME, new AllOfKeyword(subschemas));
            } else {
                keywords.put(OneOfKeyword.KEYWORD_NAME, new OneOfKeyword(subschemas));
            }

            cachedSchema.setKeywords(keywords);
            return cachedSchema;
        }

        if (innerSchema instanceof Schema inner) {
            LinkedHashMap<String, Keyword> merged = new LinkedHashMap<>(inner.getKeywords());
            merged.putAll(keywords);
            cachedSchema.setKeywords(merged);
        } else {
            cachedSchema.setKeywords(keywords);
        }
        return cachedSchema;
    }

    public Object parseBasicType(Type type) {
        Type referredType = TypeUtils.getReferredType(type);

        TypeKeyword typeKeyword = extractTypeKeyword(new ArrayList<>(List.of(referredType)));
        LinkedHashMap<String, Keyword> keywords = new LinkedHashMap<>();
        if (typeKeyword != null) {
            keywords.put(TypeKeyword.KEYWORD_NAME, typeKeyword);
        }

        extractConstOrEnumKeyword(new ArrayList<>(List.of(referredType)), keywords);
        Object err = extractKeywordsFromAnnotations(type, keywords);
        if (err instanceof BError) {
            return err;
        }

        boolean isAllOf = keywords.containsKey(AllOfKeyword.KEYWORD_NAME);
        boolean isOneOf = keywords.containsKey(OneOfKeyword.KEYWORD_NAME);

        if (isAllOf || isOneOf) {
            LinkedHashMap<String, Keyword> wrappedKeywords = new LinkedHashMap<>(keywords);
            wrappedKeywords.remove(AllOfKeyword.KEYWORD_NAME);
            wrappedKeywords.remove(OneOfKeyword.KEYWORD_NAME);

            List<Object> subschemas = new ArrayList<>();
            if (!wrappedKeywords.isEmpty()) {
                subschemas.add(new Schema(wrappedKeywords));
            }

            keywords.clear();
            if (isAllOf) {
                keywords.put(AllOfKeyword.KEYWORD_NAME, new AllOfKeyword(subschemas));
            } else {
                keywords.put(OneOfKeyword.KEYWORD_NAME, new OneOfKeyword(subschemas));
            }
        }

        if (referredType.getTag() == TypeTags.JSON_TAG && keywords.isEmpty()) {
            return true;
        } else if (referredType.getTag() == TypeTags.NEVER_TAG) {
            return false;
        }

        return new Schema(keywords);
    }

    public Object parseUnionType(Type type) {
        Type referredType = TypeUtils.getReferredType(type);
        if (!(referredType instanceof UnionType unionType)) {
            return null;
        }
        LinkedHashMap<String, Keyword> keywords = new LinkedHashMap<>();
        Object err = extractKeywordsFromAnnotations(type, keywords);
        if (err instanceof BError) {
            return err;
        }

        List<Type> memberTypes = unionType.getOriginalMemberTypes();
        List<Object> memberSchemas = new ArrayList<>();

        for (Type memberType : memberTypes) {
            Object parsedMember = parse(memberType);
            if (parsedMember instanceof Schema || parsedMember instanceof Boolean) {
                memberSchemas.add(parsedMember);
            } else {
                return (BError) parsedMember;
            }
        }

        boolean isAllOf = keywords.containsKey(AllOfKeyword.KEYWORD_NAME);
        boolean isOneOf = keywords.containsKey(OneOfKeyword.KEYWORD_NAME);

        if (!memberSchemas.isEmpty()) {
            if (isAllOf || isOneOf) {
                List<Object> wrapperList = new ArrayList<>(memberSchemas);

                if (isAllOf) {
                    keywords.put(AllOfKeyword.KEYWORD_NAME, new AllOfKeyword(wrapperList));
                    keywords.remove(OneOfKeyword.KEYWORD_NAME);
                } else {
                    keywords.put(OneOfKeyword.KEYWORD_NAME, new OneOfKeyword(wrapperList));
                    keywords.remove(AllOfKeyword.KEYWORD_NAME);
                }

            } else {
                keywords.put(AnyOfKeyword.KEYWORD_NAME, new AnyOfKeyword(memberSchemas));
            }
        } else {
            keywords.remove(AllOfKeyword.KEYWORD_NAME);
            keywords.remove(OneOfKeyword.KEYWORD_NAME);
        }

        return new Schema(keywords);
    }

    public Object parseRecordType(Type type) {
        Type referredType = TypeUtils.getReferredType(type);

        if (!(referredType instanceof RecordType recordType)) {
            return DiagnosticLog.createJsonError("expected record type, got: " + referredType);
        }

        LinkedHashMap<String, Keyword> keywords = new LinkedHashMap<>();
        keywords.put(TypeKeyword.KEYWORD_NAME, new TypeKeyword(new HashSet<>(Set.of("object"))));

        Map<String, Field> fields = recordType.getFields();
        Type restType = recordType.getRestFieldType();

        if (restType == null && fields.isEmpty()) {
            Object err = extractKeywordsFromAnnotations(referredType, keywords);
            if (err instanceof BError) {
                return err;
            }
            if (keywords.get("propertyNames") == null) {
                keywords.put(PropertyNamesKeyword.KEYWORD_NAME, new PropertyNamesKeyword(false));
            }
            return new Schema(keywords);
        }

        HashMap<String, Object> propertiesMap = new HashMap<>();
        ArrayList<String> requiredFieldNames = new ArrayList<>();

        for (String fieldName : fields.keySet()) {
            Field field = fields.get(fieldName);
            Object fieldSchema = parse(field.getFieldType());
            if (fieldSchema instanceof BError) {
                return fieldSchema;
            }
            propertiesMap.put(fieldName, fieldSchema);

            boolean isOptional = SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.OPTIONAL);
            if (!isOptional) {
                requiredFieldNames.add(fieldName);
            }
        }

        keywords.put(PropertiesKeyword.KEYWORD_NAME, new PropertiesKeyword(propertiesMap));
        if (!requiredFieldNames.isEmpty()) {
            keywords.put(RequiredKeyword.KEYWORD_NAME, new RequiredKeyword(requiredFieldNames));
        }

        Object err = extractKeywordsFromAnnotations(referredType, keywords);
        if (err instanceof BError) {
            return err;
        }
        err = extractKeywordsFromFieldAnnotations(referredType, keywords);
        if (err instanceof BError) {
            return err;
        }

        if (restType != null) {
            // TODO: Unevaluated properties have a rest type of json as well, check that too
            if (!keywords.containsKey(AdditionalPropertiesKeyword.KEYWORD_NAME)
                    && restType.getTag() != TypeTags.JSON_TAG) {
                Object restSchema = parse(restType);
                if (restSchema instanceof BError) {
                    return restSchema;
                }
                keywords.put(AdditionalPropertiesKeyword.KEYWORD_NAME, new AdditionalPropertiesKeyword(restSchema));
            }
        } else {
            if (!keywords.containsKey(AdditionalPropertiesKeyword.KEYWORD_NAME)) {
                keywords.put(AdditionalPropertiesKeyword.KEYWORD_NAME, new AdditionalPropertiesKeyword(false));
            }
        }

        return new Schema(keywords);
    }

    public Object parseArrayType(Type type) {
        Type referredType = TypeUtils.getReferredType(type);

        LinkedHashMap<String, Keyword> keywords = new LinkedHashMap<>();

        Set<String> typeNames = new HashSet<>();
        typeNames.add("array");
        keywords.put(TypeKeyword.KEYWORD_NAME, new TypeKeyword(typeNames));

        Object err = extractKeywordsFromAnnotations(type, keywords);
        if (err instanceof BError) {
            return err;
        }

        if (referredType.getTag() == TypeTags.ARRAY_TAG) {
            return parseSimpleArray(type, keywords);
        } else if (referredType.getTag() == TypeTags.TUPLE_TAG) {
            return parseTupleType(type, keywords);
        }

        return DiagnosticLog.createJsonError("unsupported array type: " + referredType);
    }

    private Object parseSimpleArray(Type type, LinkedHashMap<String, Keyword> keywords) {
        ArrayType arrayType = (ArrayType) TypeUtils.getReferredType(type);

        Type elementType = arrayType.getElementType();
        Object itemsSchema = parse(elementType);
        if (itemsSchema instanceof BError) {
            return itemsSchema;
        }
        keywords.put(ItemsKeyword.KEYWORD_NAME, new ItemsKeyword(itemsSchema));

        if (arrayType.getSize() != -1) {
            setArraySizeConstraints(keywords, (long) arrayType.getSize(), (long) arrayType.getSize());
        }

        return new Schema(keywords);
    }

    private Object parseTupleType(Type type, LinkedHashMap<String, Keyword> keywords) {
        TupleType tupleType = (TupleType) TypeUtils.getReferredType(type);
        List<Type> tupleTypes = tupleType.getTupleTypes();
        Type restType = tupleType.getRestType();

        if (restType == null && !tupleTypes.isEmpty()) {
            boolean allConstTupleMembers = true;
            for (Type memberType : tupleTypes) {
                Object constValue = extractConstValues(memberType);
                if (constValue == null || constValue instanceof Set) {
                    allConstTupleMembers = false;
                    break;
                }
            }

            if (allConstTupleMembers) {
                extractConstOrEnumKeyword(new ArrayList<>(List.of(tupleType)), keywords);
                return new Schema(keywords);
            }
        }

        if (tupleTypes.isEmpty()) {
            if (restType == null) {
                return DiagnosticLog.createJsonError("cannot create schema for empty tuple");
            }
        }

        return parseTuple(type, tupleTypes, restType, keywords);
    }

    private Object parseTuple(Type type, List<Type> tupleTypes, Type restType,
                              LinkedHashMap<String, Keyword> keywords) {
        List<Object> annotatedPrefixItemTypes = extractAnnotatedPrefixItemTypes(type);
        Keyword prefixItemsKeyword = keywords.get(PrefixItemsKeyword.KEYWORD_NAME);

        if (prefixItemsKeyword == null) {
            List<Object> prefixSchemas = new ArrayList<>();
            for (Type memberType : tupleTypes) {
                Object memberSchema;
                if (memberType.getTag() == TypeTags.INTERSECTION_TAG
                        || memberType.getTag() == TypeTags.FINITE_TYPE_TAG) {
                    LinkedHashMap<String, Keyword> memberKeywords = new LinkedHashMap<>();
                    extractConstOrEnumKeyword(new ArrayList<>(List.of(memberType)), memberKeywords);
                    if (memberKeywords.isEmpty()) {
                        memberSchema = parse(memberType);
                        if (memberSchema instanceof BError) {
                            return memberSchema;
                        }
                    } else {
                        memberSchema = new Schema(memberKeywords);
                    }
                } else {
                    memberSchema = parse(memberType);
                    if (memberSchema instanceof BError) {
                        return memberSchema;
                    }
                }
                prefixSchemas.add(memberSchema);
            }

            if (!prefixSchemas.isEmpty()) {
                keywords.put(PrefixItemsKeyword.KEYWORD_NAME, new PrefixItemsKeyword(prefixSchemas));
            }
        }

        if (restType != null && !keywords.containsKey(ItemsKeyword.KEYWORD_NAME) && !isDeclaredJsonType(restType)) {
            Object restSchema = createItemsSchemaForTupleRest(restType, annotatedPrefixItemTypes);
            if (restSchema instanceof BError) {
                return restSchema;
            }
            if (!(restSchema instanceof Boolean boolSchema) || !boolSchema) {
                keywords.put(ItemsKeyword.KEYWORD_NAME, new ItemsKeyword(restSchema));
            }
        }

        return new Schema(keywords);
    }

    private Object createItemsSchemaForTupleRest(Type restType, List<Object> annotatedPrefixItemTypes) {
        if (annotatedPrefixItemTypes == null || annotatedPrefixItemTypes.isEmpty()) {
            return parse(restType);
        }

        if (isDeclaredJsonType(restType)) {
            if (annotatedPrefixItemTypes.size() == 1 &&
                    matchesAnnotatedPrefixItem(restType, annotatedPrefixItemTypes.getFirst())) {
                return false;
            }
            return parse(restType);
        }

        Type referredRestType = TypeUtils.getReferredType(restType);
        if (!(referredRestType instanceof UnionType unionType)) {
            if (annotatedPrefixItemTypes.size() == 1 &&
                    matchesAnnotatedPrefixItem(restType, annotatedPrefixItemTypes.getFirst())) {
                return false;
            }
            return parse(restType);
        }

        List<Type> remainingMembers = new ArrayList<>(unionType.getOriginalMemberTypes());

        for (Object prefixItemType : annotatedPrefixItemTypes) {
            for (int i = 0; i < remainingMembers.size(); i++) {
                if (matchesAnnotatedPrefixItem(remainingMembers.get(i), prefixItemType)) {
                    remainingMembers.remove(i);
                    break;
                }
            }
        }

        if (remainingMembers.isEmpty()) {
            return false;
        }

        if (remainingMembers.size() == 1) {
            return parse(remainingMembers.getFirst());
        }

        LinkedHashMap<String, Keyword> keywords = new LinkedHashMap<>();
        ArrayList<Type> constValues = new ArrayList<>();
        List<Object> memberSchemas = new ArrayList<>();

        TypeKeyword typeKeyword = extractTypeKeyword(new ArrayList<>(remainingMembers));
        if (typeKeyword != null && typeKeyword.keywordValue.containsAll(
                Set.of("string", "number", "boolean", "object", "array", "null"))) {
            typeKeyword = null;
        }

        for (Type memberType : remainingMembers) {
            if (memberType.getTag() == TypeTags.TYPE_REFERENCED_TYPE_TAG
                    || memberType.getTag() == TypeTags.ARRAY_TAG) {
                Object parsedMember = parse(memberType);
                if (parsedMember instanceof Schema || parsedMember instanceof Boolean) {
                    memberSchemas.add(parsedMember);
                } else {
                    return (BError) parsedMember;
                }
            } else if (memberType.getTag() == TypeTags.TUPLE_TAG) {
                TupleType tupleType = (TupleType) memberType;
                ArrayList<Type> tupleMembers = new ArrayList<>(tupleType.getTupleTypes());
                boolean allConstOrEnum = true;

                for (Type tupleMember : tupleMembers) {
                    Object tupleMemberConst = extractConstValues(tupleMember);
                    if (tupleMemberConst == null || tupleMemberConst instanceof Set) {
                        allConstOrEnum = false;
                        break;
                    }
                }

                if (allConstOrEnum && tupleType.getRestType() == null) {
                    constValues.add(memberType);
                } else {
                    Object parsedMember = parse(memberType);
                    if (parsedMember instanceof Schema || parsedMember instanceof Boolean) {
                        memberSchemas.add(parsedMember);
                    } else {
                        return (BError) parsedMember;
                    }
                }
            } else {
                Object memberConst = extractConstValues(memberType);
                if (memberConst != null && !(memberConst instanceof Set)) {
                    constValues.add(memberType);
                    continue;
                }

                Object parsedMember = parse(memberType);
                if (parsedMember instanceof Schema || parsedMember instanceof Boolean) {
                    memberSchemas.add(parsedMember);
                } else {
                    return parsedMember;
                }
            }
        }

        if (typeKeyword != null) {
            keywords.put(TypeKeyword.KEYWORD_NAME, typeKeyword);
        }

        if (!constValues.isEmpty()) {
            extractConstOrEnumKeyword(constValues, keywords);
        }

        if (!memberSchemas.isEmpty()) {
            keywords.put(AnyOfKeyword.KEYWORD_NAME, new AnyOfKeyword(memberSchemas));
        }

        return new Schema(keywords);
    }

    private boolean isDeclaredJsonType(Type type) {
        if (type.getTag() == TypeTags.JSON_TAG) {
            return true;
        }

        if (type.getTag() == TypeTags.TYPE_REFERENCED_TYPE_TAG) {
            return isDeclaredJsonType(((ReferenceType) type).getReferredType());
        }

        return false;
    }

    private boolean matchesAnnotatedPrefixItem(Type memberType, Object prefixItem) {
        if (prefixItem instanceof Type prefixItemType) {
            return isSameDeclaredType(memberType, prefixItemType);
        }

        if (prefixItem == null && TypeUtils.getReferredType(memberType).getTag() == TypeTags.NULL_TAG) {
            return true;
        }

        Object constValue = extractConstValues(memberType);
        if (constValue == null || constValue instanceof Set) {
            return false;
        }

        return JsonEqualityUtils.deepEquals(
                SchemaParserUtils.normalizeConstValue(constValue, NULL_CONST),
                prefixItem
        );
    }

    private boolean isSameDeclaredType(Type left, Type right) {
        if (left == right) {
            return true;
        }

        String leftName = left.getName();
        String rightName = right.getName();
        if (leftName != null || rightName != null) {
            return Objects.equals(leftName, rightName);
        }

        if (left.getTag() != right.getTag()) {
            return false;
        }

        return Objects.equals(left.toString(), right.toString());
    }

    public TypeKeyword extractTypeKeyword(ArrayList<Type> types) {
        TypeKeyword typeKeyword = null;
        Set<String> typeNames = new HashSet<>();

        for (Type memberType : types) {
            Type referredType = TypeUtils.getReferredType(memberType);
            switch (referredType.getTag()) {
                case TypeTags.JSON_TAG -> {
                    typeNames.add("string");
                    typeNames.add("number");
                    typeNames.add("boolean");
                    typeNames.add("object");
                    typeNames.add("array");
                    typeNames.add("null");
                }
                case TypeTags.STRING_TAG -> typeNames.add("string");
                case TypeTags.INT_TAG -> {
                    if (!typeNames.contains("number")) {
                        typeNames.add("integer");
                    }
                }
                case TypeTags.FLOAT_TAG, TypeTags.DECIMAL_TAG -> {
                    typeNames.remove("integer");
                    typeNames.add("number");
                }
                case TypeTags.BOOLEAN_TAG -> typeNames.add("boolean");
                case TypeTags.RECORD_TYPE_TAG, TypeTags.MAP_TAG -> typeNames.add("object");
                case TypeTags.ARRAY_TAG, TypeTags.TUPLE_TAG -> typeNames.add("array");
                case TypeTags.UNION_TAG -> {
                    TypeKeyword nestedTypeKeyword = extractTypeKeyword(
                            new ArrayList<>(((UnionType) referredType).getOriginalMemberTypes()));
                    if (nestedTypeKeyword != null) {
                        typeNames.addAll(nestedTypeKeyword.keywordValue);
                    }
                }
                default -> {
                }
            }
        }

        if (!typeNames.isEmpty()) {
            typeKeyword = new TypeKeyword(typeNames);
        }

        if (typeNames.contains("number")) {
            typeNames.remove("integer");
        }
        return typeKeyword;
    }

    public void extractConstOrEnumKeyword(ArrayList<Type> referredTypes, LinkedHashMap<String, Keyword> keywords) {
        Set<Object> constValues = new HashSet<>();
        for (Type type : referredTypes) {
            Object constValue = extractConstValues(type);
            if (constValue != null) {
                if (constValue instanceof Set) {
                    constValues.addAll((Set<?>) constValue);
                } else {
                    constValues.add(SchemaParserUtils.normalizeConstValue(constValue, NULL_CONST));
                }
            }
        }
        if (constValues.size() == 1) {
            Object constValue = constValues.iterator().next();
            keywords.put(ConstKeyword.KEYWORD_NAME, new ConstKeyword(constValue));
        } else if (constValues.size() > 1) {
            keywords.put(EnumKeyword.KEYWORD_NAME, new EnumKeyword(constValues));
        }
    }

    // Forcing all () cases to be handled by const instead of type keyword
    private Object extractConstValues(Type type) {
        if (type.getTag() == TypeTags.INTERSECTION_TAG) {
            Type effectiveType = ((IntersectionType) type).getEffectiveType();
            return extractConstValues(effectiveType);
        } else if (type.getTag() == TypeTags.NULL_TAG) {
            return NULL_CONST;
        } else if (type.getTag() == TypeTags.FINITE_TYPE_TAG) {
            FiniteType finiteType = (FiniteType) type;
            if (finiteType.getValueSpace().size() == 1) {
                Object value = finiteType.getValueSpace().iterator().next();
                return value == null ? NULL_CONST : value;
            } else {
                return new HashSet<>(finiteType.getValueSpace());
            }
        } else if (type.getTag() == TypeTags.RECORD_TYPE_TAG) {
            RecordType recordType = (RecordType) type;
            if ((recordType.getFlags() & SymbolFlags.READONLY) == SymbolFlags.READONLY) {
                BMap<BString, Object> bMap = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
                for (Entry<String, Field> entry : recordType.getFields().entrySet()) {
                    String fieldName = entry.getKey();
                    Field field = entry.getValue();
                    Object fieldValue = extractConstValues(field.getFieldType());
                    if (fieldValue == null || fieldValue instanceof Set) {
                        return null;
                    }
                    bMap.put(StringUtils.fromString(fieldName),
                            SchemaParserUtils.normalizeConstValue(fieldValue, NULL_CONST));
                }
                return bMap;
            }
        } else if (type.getTag() == TypeTags.TUPLE_TAG) {
            TupleType tupleType = (TupleType) type;
            BArray bArray = ValueCreator.createArrayValue(
                    TypeCreator.createArrayType(PredefinedTypes.TYPE_ANY));

            int index = 0;
            for (Type memberType : tupleType.getTupleTypes()) {
                Object memberValue = extractConstValues(memberType);
                if (memberValue == null) {
                    return null;
                } else {
                    bArray.add(index, SchemaParserUtils.normalizeConstValue(memberValue, NULL_CONST));
                }
                index += 1;
            }
            return bArray;
        }

        return null;
    }

    public Object extractKeywordsFromAnnotations(Type referredType, LinkedHashMap<String, Keyword> keywords) {
        if (keywords == null) {
            keywords = new LinkedHashMap<>();
        }
        final LinkedHashMap<String, Keyword> finalKeywords = keywords;

        if (!(referredType instanceof AnnotatableType annotatableType)) {
            return null;
        }

        BMap<BString, Object> annotations = annotatableType.getAnnotations();

        if (annotations.isEmpty()) {
            return null;
        }

        Pattern annotationNamePattern = Pattern.compile("([^:]+)$");

        for (BString key : annotations.getKeys()) {
            String annotationIdentifier = key.getValue();
            Matcher matcher = annotationNamePattern.matcher(annotationIdentifier);
            String annotationName = matcher.find() ? matcher.group(1) : annotationIdentifier;

            Object annotation = annotations.get(key);

            switch (annotationName) {
                case "StringConstraints":
                    extractStringValidationKeywords((BMap<BString, Object>) annotation, keywords);
                    break;
                case "NumberConstraints":
                    extractNumericValidationKeywords((BMap<BString, Object>) annotation, keywords);
                    break;
                case "ArrayConstraints": {
                    Object err = extractArrayValidationKeywords((BMap<BString, Object>) annotation, keywords);
                    if (err instanceof BError) {
                        return err;
                    }
                    break;
                }
                case "ObjectConstraints": {
                    Object err = extractObjectValidationKeywords((BMap<BString, Object>) annotation, keywords);
                    if (err instanceof BError) {
                        return err;
                    }
                    break;
                }
                case "PatternProperties": {
                    Object err = extractPatternProperties((BMap<BString, Object>) annotation, keywords);
                    if (err instanceof BError) {
                        return err;
                    }
                    break;
                }
                case "AdditionalProperties": {
                    Object err = extractAdditionalProperties((BMap<BString, Object>) annotation, keywords);
                    if (err instanceof BError) {
                        return err;
                    }
                    break;
                }
                case "ReadOnly":
                    keywords.put(ReadOnlyKeyword.KEYWORD_NAME, new ReadOnlyKeyword(true));
                    break;
                case "WriteOnly":
                    keywords.put(WriteOnlyKeyword.KEYWORD_NAME, new WriteOnlyKeyword(true));
                    break;
                case "MetaData":
                    extractMetaDataKeywords((BMap<BString, Object>) annotation, keywords);
                    break;
                case "StringEncodedData": {
                    Object err = extractStringEncodedDataKeywords((BMap<BString, Object>) annotation, keywords);
                    if (err instanceof BError) {
                        return err;
                    }
                    break;
                }
                case "AllOf":
                    keywords.put(AllOfKeyword.KEYWORD_NAME, new AllOfKeyword(new ArrayList<>()));
                    break;
                case "OneOf":
                    keywords.put(OneOfKeyword.KEYWORD_NAME, new OneOfKeyword(new ArrayList<>()));
                    break;
                case "Not":
                    if (!(annotation instanceof BMap<?, ?> notAnnotation)) {
                        break;
                    }
                    Object notSchema = parseSchemaFromTypeDescOrConst((BMap<BString, Object>) notAnnotation,
                            Constants.VALUE);
                    if (notSchema instanceof BError) {
                        return notSchema;
                    }
                    if (notSchema instanceof Schema || notSchema instanceof Boolean) {
                        finalKeywords.put(NotKeyword.KEYWORD_NAME, new NotKeyword(notSchema));
                    }
                    break;
                case "UnevaluatedProperties": {
                    Object err = extractUnevaluatedProperties((BMap<BString, Object>) annotation, keywords);
                    if (err instanceof BError) {
                        return err;
                    }
                    break;
                }
                case "UnevaluatedItems": {
                    Object err = extractedUnevaluatedItems((BMap<BString, Object>) annotation, keywords);
                    if (err instanceof BError) {
                        return err;
                    }
                    break;
                }
                default:
                    break;
            }
        }
        return null;
    }

    public Object extractKeywordsFromFieldAnnotations(Type type, LinkedHashMap<String, Keyword> keywords) {
        if (!(type instanceof AnnotatableType annotatableType)) {
            return null;
        }

        BMap<BString, Object> annotations = annotatableType.getAnnotations();

        if (annotations.isEmpty()) {
            return null;
        }

        Pattern annotationNamePattern = Pattern.compile("([^:]+)$");

        Map<String, List<String>> dependentRequiredMap = new LinkedHashMap<>();
        Map<String, Object> dependentSchemasMap = new LinkedHashMap<>();

        for (BString key : annotations.getKeys()) {
            String annotationIdentifier = key.getValue();
            String[] parts = annotationIdentifier.split(Constants.FIELD_REGEX);

            if (parts.length < 2) {
                continue;
            }

            String fieldName = parts[1];
            Object fieldAnnotations = annotations.get(key);

            if (!(fieldAnnotations instanceof BMap<?, ?>)) {
                continue;
            }

            BMap<BString, Object> fieldAnnotationMap = (BMap<BString, Object>) fieldAnnotations;

            for (BString fieldKey : fieldAnnotationMap.getKeys()) {
                String fieldAnnotationIdentifier = fieldKey.getValue();
                Matcher annotationMatcher = annotationNamePattern.matcher(fieldAnnotationIdentifier);
                String annotationName = annotationMatcher.find() ? annotationMatcher.group(1)
                        : fieldAnnotationIdentifier;

                Object annotation = fieldAnnotationMap.get(fieldKey);

                switch (annotationName) {
                    case "DependentRequired":
                        extractDependentRequiredAnnotation(fieldName, annotation, dependentRequiredMap);
                        break;
                    case "DependentSchema":
                        Object depErr = extractDependentSchemaAnnotation(fieldName, annotation, dependentSchemasMap);
                        if (depErr instanceof BError) {
                            return depErr;
                        }
                        break;
                    default:
                        break;
                }
            }
        }

        if (!dependentRequiredMap.isEmpty()) {
            keywords.put(DependentRequiredKeyword.KEYWORD_NAME, new DependentRequiredKeyword(dependentRequiredMap));
        }

        if (!dependentSchemasMap.isEmpty()) {
            for (Object schema : dependentSchemasMap.values()) {
                if (schema instanceof BError) {
                    return schema;
                }
            }

            Map<String, Object> mergedDependentSchemas = new LinkedHashMap<>();
            Keyword existingDepSchemas = keywords.get(DependentSchemasKeyword.KEYWORD_NAME);
            if (existingDepSchemas instanceof DependentSchemasKeyword existing) {
                mergedDependentSchemas.putAll((Map<String, Object>) existing.getKeywordValue());
            }
            mergedDependentSchemas.putAll(dependentSchemasMap);
            keywords.put(DependentSchemasKeyword.KEYWORD_NAME,
                    new DependentSchemasKeyword(mergedDependentSchemas));
        }
        return null;
    }

    private void extractDependentRequiredAnnotation(String fieldName, Object annotation,
                                                    Map<String, List<String>> dependentRequiredMap) {
        if (!(annotation instanceof BMap<?, ?> annotationMap)) {
            return;
        }

        if (!annotationMap.containsKey(Constants.VALUE)) {
            return;
        }

        Object value = annotationMap.get(Constants.VALUE);
        List<String> dependentFields = new ArrayList<>();

        if (value instanceof BString stringValue) {
            dependentFields.add(stringValue.getValue());
        } else if (value instanceof BArray arrayValue) {
            for (long i = 0; i < arrayValue.size(); i++) {
                Object element = arrayValue.get(i);
                if (element instanceof BString stringElement) {
                    dependentFields.add(stringElement.getValue());
                }
            }
        }

        if (!dependentFields.isEmpty()) {
            dependentRequiredMap.put(fieldName, dependentFields);
        }
    }

    private Object extractDependentSchemaAnnotation(String fieldName, Object annotation,
                                                 Map<String, Object> dependentSchemasMap) {
        if (!(annotation instanceof BMap<?, ?>)) {
            return null;
        }

        Object schema = parseSchemaFromTypeDescOrConst((BMap<BString, Object>) annotation, Constants.VALUE);
        if (schema instanceof BError) {
            return schema;
        }
        if (schema instanceof Schema || schema instanceof Boolean) {
            dependentSchemasMap.put(fieldName, schema);
        }
        return null;
    }

    private void setArraySizeConstraints(LinkedHashMap<String, Keyword> keywords,
                                         Long derivedMin, Long derivedMax) {
        Keyword minKeyword = keywords.get(MinItemsKeyword.KEYWORD_NAME);
        Keyword maxKeyword = keywords.get(MaxItemsKeyword.KEYWORD_NAME);
        Long annotatedMin = minKeyword != null ? (Long) minKeyword.getKeywordValue() : null;
        Long annotatedMax = maxKeyword != null ? (Long) maxKeyword.getKeywordValue() : null;

        Long finalMin = mergeMinConstraints(annotatedMin, derivedMin);
        Long finalMax = mergeMaxConstraints(annotatedMax, derivedMax);

        if (finalMin != null) {
            keywords.put(MinItemsKeyword.KEYWORD_NAME, new MinItemsKeyword(finalMin));
        }
        if (finalMax != null) {
            keywords.put(MaxItemsKeyword.KEYWORD_NAME, new MaxItemsKeyword(finalMax));
        }
    }

    private Long mergeMinConstraints(Long annotated, Long derived) {
        if (annotated == null) {
            return derived;
        }
        if (derived == null) {
            return annotated;
        }
        return Math.max(annotated, derived);
    }

    private Long mergeMaxConstraints(Long annotated, Long derived) {
        if (annotated == null) {
            return derived;
        }
        if (derived == null) {
            return annotated;
        }
        return Math.min(annotated, derived);
    }

    private void extractNumericValidationKeywords(BMap<BString, Object> annotation,
                                                  LinkedHashMap<String, Keyword> keywords) {
        SchemaParserUtils.extractDouble(annotation, "minimum").ifPresent(value ->
                keywords.put(MinimumKeyword.KEYWORD_NAME, new MinimumKeyword(value))
        );
        SchemaParserUtils.extractDouble(annotation, "maximum").ifPresent(value ->
                keywords.put(MaximumKeyword.KEYWORD_NAME, new MaximumKeyword(value))
        );
        SchemaParserUtils.extractDouble(annotation, "exclusiveMinimum").ifPresent(value ->
                keywords.put(ExclusiveMinimumKeyword.KEYWORD_NAME, new ExclusiveMinimumKeyword(value))
        );
        SchemaParserUtils.extractDouble(annotation, "exclusiveMaximum").ifPresent(value ->
                keywords.put(ExclusiveMaximumKeyword.KEYWORD_NAME, new ExclusiveMaximumKeyword(value))
        );
        SchemaParserUtils.extractDouble(annotation, "multipleOf").ifPresent(value ->
                keywords.put(MultipleOfKeyword.KEYWORD_NAME, new MultipleOfKeyword(value))
        );
    }

    private void extractStringValidationKeywords(BMap<BString, Object> annotation,
                                                 LinkedHashMap<String, Keyword> keywords) {
        SchemaParserUtils.extractLong(annotation, "minLength").ifPresent(value ->
                keywords.put(MinLengthKeyword.KEYWORD_NAME, new MinLengthKeyword(value))
        );
        SchemaParserUtils.extractLong(annotation, "maxLength").ifPresent(value ->
                keywords.put(MaxLengthKeyword.KEYWORD_NAME, new MaxLengthKeyword(value))
        );

        BString patternKey = StringUtils.fromString("pattern");
        if (annotation.containsKey(patternKey)) {
            Object value = annotation.get(patternKey);
            if (value instanceof BRegexpValue regExVal) {
                keywords.put(PatternKeyword.KEYWORD_NAME, new PatternKeyword(regExVal));
            } else if (value instanceof BString strVal) {
                keywords.put(PatternKeyword.KEYWORD_NAME, new PatternKeyword(strVal));
            }
        }

        BString formatKey = StringUtils.fromString("format");
        if (annotation.containsKey(formatKey)) {
            Object value = annotation.get(formatKey);
            if (value instanceof BString strVal) {
                keywords.put(FormatKeyword.KEYWORD_NAME, new FormatKeyword(strVal.getValue()));
            }
        }
    }

    private Object extractArrayValidationKeywords(BMap<BString, Object> annotation,
                                                  LinkedHashMap<String, Keyword> keywords) {
        BString prefixItemsKey = StringUtils.fromString("prefixItems");
        if (annotation.containsKey(prefixItemsKey)) {
            Object prefixItemsObj = annotation.get(prefixItemsKey);
            if (prefixItemsObj instanceof BArray prefixItemsArray) {
                List<Object> prefixSchemas = new ArrayList<>();
                for (long i = 0; i < prefixItemsArray.getLength(); i++) {
                    Object prefixItem = prefixItemsArray.get(i);
                    Object prefixSchema;
                    if (prefixItem instanceof BTypedesc typeDesc) {
                        prefixSchema = parse(typeDesc.getDescribingType());
                    } else if (prefixItem == null) {
                        LinkedHashMap<String, Keyword> prefixKeywords = new LinkedHashMap<>();
                        prefixKeywords.put(ConstKeyword.KEYWORD_NAME, new ConstKeyword(null));
                        prefixSchema = new Schema(prefixKeywords);
                    } else {
                        LinkedHashMap<String, Keyword> prefixKeywords = new LinkedHashMap<>();
                        prefixKeywords.put(ConstKeyword.KEYWORD_NAME, new ConstKeyword(prefixItem));
                        prefixSchema = new Schema(prefixKeywords);
                    }
                    if (prefixSchema instanceof BError) {
                        return prefixSchema;
                    }
                    if (prefixSchema instanceof Schema || prefixSchema instanceof Boolean) {
                        prefixSchemas.add(prefixSchema);
                    }
                }
                keywords.put(PrefixItemsKeyword.KEYWORD_NAME, new PrefixItemsKeyword(prefixSchemas));
            }
        }

        SchemaParserUtils.extractLong(annotation, "minItems").ifPresent(value ->
                keywords.put(MinItemsKeyword.KEYWORD_NAME, new MinItemsKeyword(value))
        );
        SchemaParserUtils.extractLong(annotation, "maxItems").ifPresent(value ->
                keywords.put(MaxItemsKeyword.KEYWORD_NAME, new MaxItemsKeyword(value))
        );
        SchemaParserUtils.extractBoolean(annotation, "uniqueItems").ifPresent(value ->
                keywords.put(UniqueItemsKeyword.KEYWORD_NAME, new UniqueItemsKeyword(value))
        );
        BString itemsKey = StringUtils.fromString("items");
        if (annotation.containsKey(itemsKey)) {
            Object schema = parseSchemaFromTypeDescOrConst(annotation, itemsKey);
            if (schema instanceof BError) {
                return schema;
            }
            if (schema instanceof Schema || schema instanceof Boolean) {
                keywords.put(ItemsKeyword.KEYWORD_NAME, new ItemsKeyword(schema));
            }
        }
        BString containsKey = StringUtils.fromString("contains");
        if (annotation.containsKey(containsKey)) {
            Object containsObj = annotation.get(containsKey);
            if (containsObj instanceof BMap<?, ?> containsConfig) {
                BMap<BString, Object> containsTypeDescMap = (BMap<BString, Object>) containsConfig;
                Long minContains = SchemaParserUtils.extractLong(containsTypeDescMap, "minContains").orElse(null);
                Long maxContains = SchemaParserUtils.extractLong(containsTypeDescMap, "maxContains").orElse(null);
                Object containsSchema = parseSchemaFromTypeDescOrConst(containsTypeDescMap, Constants.VALUE);
                if (containsSchema instanceof BError) {
                    return containsSchema;
                }
                if (containsSchema instanceof Schema || containsSchema instanceof Boolean) {
                    keywords.put(ContainsKeyword.KEYWORD_NAME,
                            new ContainsKeyword(minContains, maxContains, containsSchema));
                }
            }
        }
        BString unevaluatedItems = StringUtils.fromString("unevaluatedItems");
        if (annotation.containsKey(unevaluatedItems)) {
            Object schema = parseSchemaFromTypeDescOrConst(annotation, unevaluatedItems);
            if (schema instanceof BError) {
                return schema;
            }
            if (schema instanceof Schema || schema instanceof Boolean) {
                keywords.put(UnevaluatedItemsKeyword.KEYWORD_NAME, new UnevaluatedItemsKeyword(schema));
            }
        }
        return null;
    }

    private Object extractObjectValidationKeywords(BMap<BString, Object> annotation,
                                                   LinkedHashMap<String, Keyword> keywords) {
        ArrayList<BString> keys = new ArrayList<>(List.of(annotation.getKeys()));

        BString propertyNamesKey = StringUtils.fromString("propertyNames");
        if (keys.contains(propertyNamesKey)) {
            Object propertyNamesSchema = parseSchemaFromTypeDescOrConst(annotation, propertyNamesKey);
            if (propertyNamesSchema instanceof BError) {
                return propertyNamesSchema;
            }
            if (propertyNamesSchema instanceof Schema || propertyNamesSchema instanceof Boolean) {
                keywords.put(PropertyNamesKeyword.KEYWORD_NAME,
                        new PropertyNamesKeyword(propertyNamesSchema));
            }
        }

        SchemaParserUtils.extractLong(annotation, "minProperties").ifPresent(value ->
                keywords.put(MinPropertiesKeyword.KEYWORD_NAME, new MinPropertiesKeyword(value))
        );

        SchemaParserUtils.extractLong(annotation, "maxProperties").ifPresent(value ->
                keywords.put(MaxPropertiesKeyword.KEYWORD_NAME, new MaxPropertiesKeyword(value))
        );

        BString dependentSchemasKey = StringUtils.fromString("dependentSchemas");
        if (keys.contains(dependentSchemasKey)) {
            Object dependentSchemasValue = annotation.get(dependentSchemasKey);
            List<BMap<BString, Object>> elements = new ArrayList<>();

            if (dependentSchemasValue instanceof BMap<?, ?> elementMap) {
                elements.add((BMap<BString, Object>) elementMap);
            } else if (dependentSchemasValue instanceof BArray elementsArray) {
                for (long i = 0; i < elementsArray.size(); i++) {
                    Object element = elementsArray.get(i);
                    if (element instanceof BMap<?, ?> elementMap) {
                        elements.add((BMap<BString, Object>) elementMap);
                    }
                }
            }

            Map<String, Object> dependentSchemasMap = new LinkedHashMap<>();
            BString propertyKey = StringUtils.fromString("property");
            BString schemaKey = StringUtils.fromString("schema");

            for (BMap<BString, Object> element : elements) {
                Object propertyObj = element.get(propertyKey);
                if (!(propertyObj instanceof BString propertyName)) {
                    return DiagnosticLog.createJsonError(
                            "dependentSchemas element missing 'property' field");
                }

                Object schemaValue = element.get(schemaKey);
                Object parsedSchema;
                if (schemaValue instanceof BTypedesc typeDesc) {
                    parsedSchema = parse(typeDesc.getDescribingType());
                } else {
                    LinkedHashMap<String, Keyword> constKeywords = new LinkedHashMap<>();
                    constKeywords.put(ConstKeyword.KEYWORD_NAME, new ConstKeyword(schemaValue));
                    parsedSchema = new Schema(constKeywords);
                }

                if (parsedSchema instanceof BError) {
                    return parsedSchema;
                }
                if (parsedSchema instanceof Schema || parsedSchema instanceof Boolean) {
                    dependentSchemasMap.put(propertyName.getValue(), parsedSchema);
                }
            }

            if (!dependentSchemasMap.isEmpty()) {
                keywords.put(DependentSchemasKeyword.KEYWORD_NAME,
                        new DependentSchemasKeyword(dependentSchemasMap));
            }
        }

        return null;
    }

    private Object extractPatternProperties(BMap<BString, Object> annotation,
                                            LinkedHashMap<String, Keyword> keywords) {
        Object value = annotation.get(Constants.VALUE);
        if (value == null) {
            return null;
        }

        List<BMap<BString, Object>> elements = new ArrayList<>();
        if (value instanceof BMap) {
            elements.add((BMap<BString, Object>) value);
        } else if (value instanceof BArray array) {
            for (long i = 0; i < array.size(); i++) {
                Object element = array.get(i);
                if (element instanceof BMap) {
                    elements.add((BMap<BString, Object>) element);
                }
            }
        }

        Map<String, Object> patternSchemaMap = new LinkedHashMap<>();
        for (BMap<BString, Object> element : elements) {
            BString patternKey = StringUtils.fromString("pattern");

            if (element.containsKey(patternKey) && element.containsKey(Constants.VALUE)) {
                String pattern = element.get(patternKey).toString();
                Object schema = parseSchemaFromTypeDescOrConst(element, Constants.VALUE);
                if (schema instanceof BError) {
                    return schema;
                }
                if (schema instanceof Schema || schema instanceof Boolean) {
                    patternSchemaMap.put(pattern, schema);
                }
            }
        }

        if (!patternSchemaMap.isEmpty()) {
            keywords.put(PatternPropertiesKeyword.KEYWORD_NAME,
                   new PatternPropertiesKeyword(patternSchemaMap));
        }
        return null;
    }

    private Object extractAdditionalProperties(BMap<BString, Object> annotation,
                                               LinkedHashMap<String, Keyword> keywords) {
        if (annotation.containsKey(Constants.VALUE)) {
            Object additionalPropertiesSchema = parseSchemaFromTypeDescOrConst(annotation, Constants.VALUE);
            if (additionalPropertiesSchema instanceof BError) {
                return additionalPropertiesSchema;
            }
            if (additionalPropertiesSchema instanceof Schema || additionalPropertiesSchema instanceof Boolean) {
                keywords.put(AdditionalPropertiesKeyword.KEYWORD_NAME,
                           new AdditionalPropertiesKeyword(additionalPropertiesSchema));
            }
        }
        return null;
    }

    private Object extractUnevaluatedProperties(BMap<BString, Object> annotation,
                                               LinkedHashMap<String, Keyword> keywords) {
        Object unevaluatedPropertiesSchema = parseSchemaFromTypeDescOrConst(annotation, Constants.VALUE);
        if (unevaluatedPropertiesSchema instanceof BError) {
            return unevaluatedPropertiesSchema;
        }
        if (unevaluatedPropertiesSchema instanceof Schema || unevaluatedPropertiesSchema instanceof Boolean) {
            keywords.put(UnevaluatedPropertiesKeyword.KEYWORD_NAME,
                       new UnevaluatedPropertiesKeyword(unevaluatedPropertiesSchema));
        }
        return null;
    }

    private Object extractedUnevaluatedItems(BMap<BString, Object> annotation,
                                             LinkedHashMap<String, Keyword> keywords) {
        Object unevaluatedItemsSchema = parseSchemaFromTypeDescOrConst(annotation, Constants.VALUE);
        if (unevaluatedItemsSchema instanceof BError) {
            return unevaluatedItemsSchema;
        }
        if (unevaluatedItemsSchema instanceof Schema || unevaluatedItemsSchema instanceof Boolean) {
            keywords.put(UnevaluatedItemsKeyword.KEYWORD_NAME,
                    new UnevaluatedItemsKeyword(unevaluatedItemsSchema));
        }
        return null;
    }

    private Object extractStringEncodedDataKeywords(BMap<BString, Object> annotation,
                                                    LinkedHashMap<String, Keyword> keywords) {
        BString contentEncodingKey = StringUtils.fromString("contentEncoding");
        if (annotation.containsKey(contentEncodingKey)) {
            Object encoding = annotation.get(contentEncodingKey);
            if (encoding instanceof BString encodingValue) {
                keywords.put(ContentEncodingKeyword.KEYWORD_NAME,
                        new ContentEncodingKeyword(encodingValue.getValue()));
            }
        }
        BString contentMediaTypeKey = StringUtils.fromString("contentMediaType");
        if (annotation.containsKey(contentMediaTypeKey)) {
            Object mediaType = annotation.get(contentMediaTypeKey);
            if (mediaType instanceof BString mediaTypeValue) {
                keywords.put(ContentMediaTypeKeyword.KEYWORD_NAME,
                        new ContentMediaTypeKeyword(mediaTypeValue.getValue()));
            }
        }
        BString contentSchemaKey = StringUtils.fromString("contentSchema");
        if (annotation.containsKey(contentSchemaKey)) {
            Object contentSchema = parseSchemaFromTypeDescOrConst(annotation, contentSchemaKey);
            if (contentSchema instanceof BError) {
                return contentSchema;
            }
            if (contentSchema instanceof Schema || contentSchema instanceof Boolean) {
                keywords.put(ContentSchemaKeyword.KEYWORD_NAME, new ContentSchemaKeyword(contentSchema));
            }
        }
        return null;
    }

    private void extractMetaDataKeywords(BMap<BString, Object> annotation,
                                         LinkedHashMap<String, Keyword> keywords) {
        BString titleKey = StringUtils.fromString("title");
        if (annotation.containsKey(titleKey)) {
            Object title = annotation.get(titleKey);
            if (title instanceof BString titleValue) {
                keywords.put(TitleKeyword.KEYWORD_NAME, new TitleKeyword(titleValue.getValue()));
            }
        }
        BString examplesKey = StringUtils.fromString("examples");
        if (annotation.containsKey(examplesKey)) {
            Object examples = annotation.get(examplesKey);
            if (examples instanceof BArray examplesValue) {
                keywords.put(ExamplesKeyword.KEYWORD_NAME, new ExamplesKeyword(examplesValue));
            }
        }
        BString commentKey = StringUtils.fromString("$comment");
        if (annotation.containsKey(commentKey)) {
            Object comment = annotation.get(commentKey);
            if (comment instanceof BString commentValue) {
                keywords.put(CommentKeyword.KEYWORD_NAME, new CommentKeyword(commentValue.getValue()));
            }
        }
    }

    private Object parseSchemaFromTypeDesc(BMap<BString, Object> annotation, BString keyName) {
        Object value = annotation.get(keyName);
        if (!(value instanceof BTypedesc typeDesc)) {
            return null;
        }
        return parse(typeDesc.getDescribingType());
    }

    private Object parseSchemaFromTypeDescOrConst(BMap<BString, Object> annotation, BString keyName) {
        Object value = annotation.get(keyName);
        if (value instanceof BTypedesc typeDesc) {
            return parse(typeDesc.getDescribingType());
        }

        LinkedHashMap<String, Keyword> keywords = new LinkedHashMap<>();
        keywords.put(ConstKeyword.KEYWORD_NAME, new ConstKeyword(value));
        return new Schema(keywords);
    }

    private List<Object> extractAnnotatedPrefixItemTypes(Type type) {
        if (!(type instanceof AnnotatableType annotatableType)) {
            return null;
        }

        BMap<BString, Object> annotations = annotatableType.getAnnotations();
        if (annotations.isEmpty()) {
            return null;
        }

        Pattern annotationNamePattern = Pattern.compile("([^:]+)$");
        BString prefixItemsKey = StringUtils.fromString("prefixItems");
        for (BString key : annotations.getKeys()) {
            String annotationIdentifier = key.getValue();
            Matcher matcher = annotationNamePattern.matcher(annotationIdentifier);
            String annotationName = matcher.find() ? matcher.group(1) : annotationIdentifier;
            if (!"ArrayConstraints".equals(annotationName)) {
                continue;
            }

            Object annotation = annotations.get(key);
            if (!(annotation instanceof BMap<?, ?> annotationMap) || !annotationMap.containsKey(prefixItemsKey)) {
                return null;
            }

            Object prefixItems = annotationMap.get(prefixItemsKey);
            if (!(prefixItems instanceof BArray prefixItemsArray)) {
                return null;
            }

            List<Object> prefixItemTypes = new ArrayList<>();
            for (long i = 0; i < prefixItemsArray.getLength(); i++) {
                Object prefixItem = prefixItemsArray.get(i);
                if (prefixItem instanceof BTypedesc typeDesc) {
                    prefixItemTypes.add(typeDesc.getDescribingType());
                } else {
                    prefixItemTypes.add(prefixItem);
                }
            }
            return prefixItemTypes;
        }

        return null;
    }

    public LinkedHashMap<String, Keyword> extractAnnotationKeywords(Type type) {
        LinkedHashMap<String, Keyword> keywords = new LinkedHashMap<>();
        Type referredType = TypeUtils.getReferredType(type);
        if (referredType.getTag() == TypeTags.RECORD_TYPE_TAG) {
            Object err = extractKeywordsFromAnnotations(referredType, keywords);
            if (err instanceof BError) {
                return null;
            }
            err = extractKeywordsFromFieldAnnotations(referredType, keywords);
            if (err instanceof BError) {
                return null;
            }

            if (keywords.containsKey("additionalProperties") || keywords.containsKey("unevaluatedProperties")) {
                RecordType recordType = (RecordType) referredType;
                java.util.Map<String, Field> fields = recordType.getFields();
                if (!fields.isEmpty()) {
                    java.util.Map<String, Object> propertiesMap = new java.util.HashMap<>();
                    for (String fieldName : fields.keySet()) {
                        propertiesMap.put(fieldName, true);
                    }
                    keywords.put(PropertiesKeyword.KEYWORD_NAME, new PropertiesKeyword(propertiesMap));
                }
            }
        } else {
            Object err = extractKeywordsFromAnnotations(type, keywords);
            if (err instanceof BError) {
                return null;
            }
        }

        return keywords;
    }
}
