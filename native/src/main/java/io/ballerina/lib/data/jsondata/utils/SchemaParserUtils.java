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

package io.ballerina.lib.data.jsondata.utils;

import io.ballerina.runtime.api.utils.JsonUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;


import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Optional;
import java.util.stream.Stream;

public class SchemaParserUtils {

    public static final String VALID_ANCHOR_REGEX = "^[A-Za-z_][A-Za-z0-9_.-]*$";

    public static Object readSchemaFile(String filePath) {
        if (filePath == null || filePath.isEmpty()) {
            return DiagnosticLog.error(DiagnosticErrorCode.SCHEMA_PATH_NULL_OR_EMPTY);
        }
        if (!filePath.endsWith(".json")) {
            return DiagnosticLog.error(DiagnosticErrorCode.INVALID_SCHEMA_FILE_TYPE, filePath);
        }

        Path absolutePath = Paths.get(filePath).toAbsolutePath().normalize();
        if (!Files.exists(absolutePath)) {
            return DiagnosticLog.error(DiagnosticErrorCode.SCHEMA_FILE_NOT_FOUND, filePath);
        }
        if (Files.isDirectory(absolutePath)) {
            return DiagnosticLog.error(DiagnosticErrorCode.SCHEMA_PATH_IS_DIRECTORY, filePath);
        }

        try {
            String content = Files.readString(absolutePath);
            return JsonUtils.parse(content);
        } catch (IOException e) {
            return DiagnosticLog.createJsonError("Failed to read schema file: " + filePath);
        }
    }

    public static ArrayList<Object> readSiblingSchemas(String rootFilePath) {
        Path rootAbsPath = Paths.get(rootFilePath).toAbsolutePath().normalize();
        Path parentDir = rootAbsPath.getParent();
        ArrayList<Object> schemas = new ArrayList<>();

        if (parentDir == null || !Files.exists(parentDir)) {
            return schemas;
        }

        try (Stream<Path> paths = Files.walk(parentDir)) {
            paths.filter(path -> path.toString().endsWith(".json"))
                    .filter(Files::isRegularFile)
                    .filter(path -> !path.equals(rootAbsPath))
                    .forEach(path -> {
                        try {
                            String content = Files.readString(path);
                            Object schema = JsonUtils.parse(content);
                            schemas.add(schema);
                        } catch (IOException e) {
                            throw new RuntimeException("Failed to read file: " + path, e);
                        }
                    });
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return schemas;
    }

    public static Object readSchemaResource(String resourcePath) {
        try (InputStream is = SchemaParserUtils.class.getClassLoader().getResourceAsStream(resourcePath)) {
            if (is == null) {
                return null;
            }
            String content = new String(is.readAllBytes(), StandardCharsets.UTF_8);
            return JsonUtils.parse(content);
        } catch (IOException e) {
            return null;
        }
    }

    public static Long toInteger(Object value) {
        if (value instanceof Long l) {
            return l;
        } else if (value instanceof Double d) {
            return (d % 1) == 0 ? d.longValue() : null;
        } else if (value instanceof BDecimal bd) {
            BigDecimal javaDecimal = bd.decimalValue();
            boolean isInt = javaDecimal.remainder(BigDecimal.ONE).compareTo(BigDecimal.ZERO) == 0;
            return isInt ? javaDecimal.longValue() : null;
        }
        return null;
    }

    public static Double toNumber(Object value) {
        if (value instanceof Long l) {
            return l.doubleValue();
        }
        if (value instanceof Double d) {
            return d;
        }
        if (value instanceof BDecimal bd) {
            return bd.decimalValue().doubleValue();
        }
        return null;
    }

    public static boolean isValidAnchorName(String anchor) {
        if (anchor == null || anchor.isEmpty()) {
            return false;
        }
        return anchor.matches(VALID_ANCHOR_REGEX);
    }

    public static Long extractInteger(BMap<BString, Object> json, String keyName) {
        BString bKey = StringUtils.fromString(keyName);
        if (!json.containsKey(bKey)) {
            return null;
        }
        return toInteger(json.get(bKey));
    }

    public static Optional<Long> extractLong(BMap<BString, Object> annotation, String keyName) {
        BString key = StringUtils.fromString(keyName);

        if (!annotation.containsKey(key)) {
            return Optional.empty();
        }

        Object value = annotation.get(key);

        if (value instanceof Long longVal) {
            return Optional.of(longVal);
        }

        return Optional.empty();
    }

    public static Optional<Double> extractDouble(BMap<BString, Object> annotation, String keyName) {
        BString key = StringUtils.fromString(keyName);

        if (!annotation.containsKey(key)) {
            return Optional.empty();
        }

        Object value = annotation.get(key);

        if (value instanceof Long longVal) {
            return Optional.of(longVal.doubleValue());
        } else if (value instanceof Double doubleVal) {
            return Optional.of(doubleVal);
        } else if (value instanceof BDecimal decimalVal) {
            return Optional.of(decimalVal.decimalValue().doubleValue());
        }

        return Optional.empty();
    }

    public static Optional<Boolean> extractBoolean(BMap<BString, Object> annotation, String keyName) {
        BString key = StringUtils.fromString(keyName);

        if (!annotation.containsKey(key)) {
            return Optional.empty();
        }

        Object value = annotation.get(key);

        if (value instanceof Boolean boolVal) {
            return Optional.of(boolVal);
        }

        return Optional.empty();
    }

    public static String escapeJsonPointerToken(String token) {
        return token.replace("~", "~0").replace("/", "~1");
    }

    public static String unescapeJsonPointerToken(String token) {
        return token.replace("~1", "/").replace("~0", "~");
    }

    public static String encodeFragmentComponent(String s) {
        byte[] bytes = s.getBytes(StandardCharsets.UTF_8);
        StringBuilder sb = new StringBuilder(bytes.length * 3);
        for (byte b : bytes) {
            int unsigned = b & 0xFF;
            if (isFragmentAllowed(unsigned)) {
                sb.append((char) unsigned);
            } else {
                sb.append(String.format("%%%02X", unsigned));
            }
        }
        return sb.toString();
    }

    public static Object normalizeConstValue(Object constValue, Object nullConstSentinel) {
        return constValue == nullConstSentinel ? null : constValue;
    }

    private static boolean isFragmentAllowed(int c) {
        if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
            return true;
        }
        return switch (c) {
            case '-', '.', '_', '~', '!', '$', '&', '\'', '(', ')', '*', '+', ',', ';', '=', ':', '@', '/', '?' -> true;
            default -> false;
        };
    }
}
