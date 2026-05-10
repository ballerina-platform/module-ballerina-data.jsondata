package io.ballerina.lib.data.jsondata.utils;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.ItemsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator.PrefixItemsKeyword;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation.ContainsKeyword;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class SchemaValidatorUtils {
    public static void createEvaluatedItemsAnnotation(EvaluationContext context) {
        Object existingEvaluatedItems = context.getAnnotation("evaluatedItems");
        Object prefixItemsAnnotation = context.getAnnotation(PrefixItemsKeyword.KEYWORD_NAME);
        Object itemsAnnotation = context.getAnnotation(ItemsKeyword.KEYWORD_NAME);
        Object containsAnnotation = context.getAnnotation(ContainsKeyword.KEYWORD_NAME);

        Object ifEvaluatedItems = context.getAnnotation("ifEvaluatedItems");
        Object thenEvaluatedItems = context.getAnnotation("thenEvaluatedItems");
        Object elseEvaluatedItems = context.getAnnotation("elseEvaluatedItems");

        Object ifResult = context.getAnnotation("if");

        boolean allEvaluated = false;
        if (ifResult instanceof Boolean ifValid) {
            if (ifValid) {
                if (ifEvaluatedItems instanceof Boolean && (Boolean) ifEvaluatedItems) {
                    allEvaluated = true;
                } else if (thenEvaluatedItems instanceof Boolean && (Boolean) thenEvaluatedItems) {
                    allEvaluated = true;
                }
            } else {
                if (elseEvaluatedItems instanceof Boolean && (Boolean) elseEvaluatedItems) {
                    allEvaluated = true;
                }
            }
        }
        if (prefixItemsAnnotation instanceof Boolean prefixItemsBool && prefixItemsBool) {
            allEvaluated = true;
        } else if (itemsAnnotation instanceof Boolean itemsBool && itemsBool) {
            allEvaluated = true;
        } else if (containsAnnotation instanceof Boolean containsBool && containsBool) {
            allEvaluated = true;
        }
        if (existingEvaluatedItems instanceof Boolean && (Boolean) existingEvaluatedItems) {
            allEvaluated = true;
        }
        
        if (allEvaluated) {
            context.setAnnotation("evaluatedItems", true);
            return;
        }
        
        HashSet<Long> evaluatedIndices = new HashSet<>();
        if (existingEvaluatedItems instanceof List<?> existingList) {
            for (Object idx : existingList) {
                if (idx instanceof Long l) {
                    evaluatedIndices.add(l);
                } else if (idx instanceof Integer i) {
                    evaluatedIndices.add(i.longValue());
                }
            }
        }
        if (prefixItemsAnnotation instanceof Long largestIndex) {
            for (long i = 0; i <= largestIndex; i++) {
                evaluatedIndices.add(i);
            }
        }
        if (containsAnnotation instanceof List<?> containsIndices) {
            for (Object idx : containsIndices) {
                if (idx instanceof Long l) {
                    evaluatedIndices.add(l);
                } else if (idx instanceof Integer i) {
                    evaluatedIndices.add(i.longValue());
                }
            }
        }
        if (ifResult instanceof Boolean ifValid) {
            if (ifValid) {
                if (ifEvaluatedItems instanceof List<?> list) {
                    for (Object idx : list) {
                        if (idx instanceof Long l) {
                            evaluatedIndices.add(l);
                        } else if (idx instanceof Integer i) {
                            evaluatedIndices.add(i.longValue());
                        }
                    }
                }
                if (thenEvaluatedItems instanceof List<?> list) {
                    for (Object idx : list) {
                        if (idx instanceof Long l) {
                            evaluatedIndices.add(l);
                        } else if (idx instanceof Integer i) {
                            evaluatedIndices.add(i.longValue());
                        }
                    }
                }
            } else {
                if (elseEvaluatedItems instanceof List<?> list) {
                    for (Object idx : list) {
                        if (idx instanceof Long l) {
                            evaluatedIndices.add(l);
                        } else if (idx instanceof Integer i) {
                            evaluatedIndices.add(i.longValue());
                        }
                    }
                }
            }
        }
        if (!evaluatedIndices.isEmpty()) {
            context.setAnnotation("evaluatedItems", new ArrayList<>(evaluatedIndices));
        }
    }

    public static void createEvaluatedPropertiesAnnotation(EvaluationContext context) {
        Object existingEvaluatedProperties = context.getAnnotation("evaluatedProperties");
        Object propertiesAnnotation = context.getAnnotation("properties");
        Object patternPropertiesAnnotation = context.getAnnotation("patternProperties");
        Object additionalPropertiesAnnotation = context.getAnnotation("additionalProperties");

        Object ifEvaluatedProperties = context.getAnnotation("ifEvaluatedProperties");
        Object thenEvaluatedProperties = context.getAnnotation("thenEvaluatedProperties");
        Object elseEvaluatedProperties = context.getAnnotation("elseEvaluatedProperties");

        Object ifResult = context.getAnnotation("if");

        boolean allEvaluated = false;
        if (ifResult instanceof Boolean ifValid) {
            if (ifValid) {
                if (ifEvaluatedProperties instanceof Boolean && (Boolean) ifEvaluatedProperties) {
                    allEvaluated = true;
                } else if (thenEvaluatedProperties instanceof Boolean && (Boolean) thenEvaluatedProperties) {
                    allEvaluated = true;
                }
            } else {
                if (elseEvaluatedProperties instanceof Boolean && (Boolean) elseEvaluatedProperties) {
                    allEvaluated = true;
                }
            }
        }
        if (propertiesAnnotation instanceof Boolean propertiesBool && propertiesBool) {
            allEvaluated = true;
        } else if (patternPropertiesAnnotation instanceof Boolean patternPropertiesBool && patternPropertiesBool) {
            allEvaluated = true;
        } else if (additionalPropertiesAnnotation instanceof Boolean additionalPropertiesBool
                && additionalPropertiesBool) {
            allEvaluated = true;
        } else if (existingEvaluatedProperties instanceof Boolean && (Boolean) existingEvaluatedProperties) {
            allEvaluated = true;
        }
        
        if (allEvaluated) {
            context.setAnnotation("evaluatedProperties", true);
            return;
        }
        
        Set<String> evaluatedProperties = new HashSet<>();
        if (existingEvaluatedProperties instanceof Set<?> existingSet) {
            for (Object value : existingSet) {
                if (value instanceof String propertyName) {
                    evaluatedProperties.add(propertyName);
                }
            }
        }
        if (propertiesAnnotation instanceof Set<?> properties) {
            for (Object value : properties) {
                if (value instanceof String propertyName) {
                    evaluatedProperties.add(propertyName);
                }
            }
        }
        if (patternPropertiesAnnotation instanceof Set<?> patternProperties) {
            for (Object value : patternProperties) {
                if (value instanceof String propertyName) {
                    evaluatedProperties.add(propertyName);
                }
            }
        }
        if (additionalPropertiesAnnotation instanceof Set<?> additionalProperties) {
            for (Object value : additionalProperties) {
                if (value instanceof String propertyName) {
                    evaluatedProperties.add(propertyName);
                }
            }
        }
        if (ifResult instanceof Boolean ifValid) {
            if (ifValid) {
                if (ifEvaluatedProperties instanceof Set<?> ifProps) {
                    for (Object value : ifProps) {
                        if (value instanceof String propertyName) {
                            evaluatedProperties.add(propertyName);
                        }
                    }
                }
                if (thenEvaluatedProperties instanceof Set<?> thenProps) {
                    for (Object value : thenProps) {
                        if (value instanceof String propertyName) {
                            evaluatedProperties.add(propertyName);
                        }
                    }
                }
            } else {
                if (elseEvaluatedProperties instanceof Set<?> elseProps) {
                    for (Object value : elseProps) {
                        if (value instanceof String propertyName) {
                            evaluatedProperties.add(propertyName);
                        }
                    }
                }
            }
        }
        if (!evaluatedProperties.isEmpty()) {
            context.setAnnotation("evaluatedProperties", evaluatedProperties);
        }
    }
}
