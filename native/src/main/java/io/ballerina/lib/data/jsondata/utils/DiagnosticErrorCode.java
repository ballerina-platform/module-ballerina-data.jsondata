/*
 * Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.data.jsondata.utils;

/**
 * Represents a diagnostic error code.
 *
 * @since 0.1.0
 */
public enum DiagnosticErrorCode {
    UNSUPPORTED_TYPE("JSON_ERROR_001", "unsupported.type"),
    JSON_READER_FAILURE("JSON_ERROR_002", "json.reader.failure"),
    JSON_PARSER_EXCEPTION("JSON_ERROR_003", "json.parser.exception"),
    INCOMPATIBLE_TYPE("JSON_ERROR_004", "incompatible.type"),
    ARRAY_SIZE_MISMATCH("JSON_ERROR_005", "array.size.mismatch"),
    INVALID_TYPE("JSON_ERROR_006", "invalid.type"),
    INCOMPATIBLE_VALUE_FOR_FIELD("JSON_ERROR_007", "incompatible.value.for.field"),
    REQUIRED_FIELD_NOT_PRESENT("JSON_ERROR_008", "required.field.not.present"),
    INVALID_TYPE_FOR_FIELD("JSON_ERROR_009", "invalid.type.for.field"),
    DUPLICATE_FIELD("JSON_ERROR_010", "duplicate.field"),
    CANNOT_CONVERT_TO_EXPECTED_TYPE("JSON_ERROR_011", "cannot.convert.to.expected.type"),
    UNDEFINED_FIELD("JSON_ERROR_012", "undefined.field"),
    CAN_NOT_READ_STREAM("JSON_ERROR_013", "cannot.read.stream"),
    CYCLIC_REFERENCE("JSON_ERROR_014", "cyclic.reference"),
    SCHEMA_FILE_NOT_FOUND("JSON_ERROR_015", "schema.file.not.found"),
    SCHEMA_VALIDATION_FAILED("JSON_ERROR_016", "schema.validation.failed"),
    SCHEMA_PATH_NULL_OR_EMPTY("JSON_ERROR_017", "schema.path.null.or.empty"),
    INVALID_SCHEMA_FILE_TYPE("JSON_ERROR_018", "invalid.schema.file.type"),
    SCHEMA_PATH_IS_DIRECTORY("JSON_ERROR_019", "schema.path.is.directory"),
    SCHEMA_LOADING_FAILED("JSON_ERROR_020", "schema.loading.failed"),
    SCHEMAS_ARRAY_NULL_OR_EMPTY("JSON_ERROR_021", "schemas.array.null.or.empty"),
    MULTIPLE_ROOT_SCHEMAS("JSON_ERROR_022", "multiple.root.schemas"),
    MISSING_SCHEMA_ID("JSON_ERROR_023", "missing.schema.id"),
    RELATIVE_SCHEMA_ID("JSON_ERROR_024", "relative.schema.id");

    String diagnosticId;
    String messageKey;

    DiagnosticErrorCode(String diagnosticId, String messageKey) {
        this.diagnosticId = diagnosticId;
        this.messageKey = messageKey;
    }

    public String messageKey() {
        return messageKey;
    }
}
