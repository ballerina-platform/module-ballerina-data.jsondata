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

package io.ballerina.stdlib.data.jsondata.utils;

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
    UNDEFINED_FIELD("JSON_ERROR_012", "undefined.field");

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
