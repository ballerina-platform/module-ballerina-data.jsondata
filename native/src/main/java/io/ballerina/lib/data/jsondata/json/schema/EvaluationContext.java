/*
 * Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
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

package io.ballerina.lib.data.jsondata.json.schema;

import java.net.URI;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class EvaluationContext {
    private final String instanceLocationSegment;
    private final String schemaLocationSegment;
    private final EvaluationContext parent;
    private final List<String> errors;
    private String instanceLocation;
    private String schemaLocation;
    private HashMap<String, Object> annotations;
    private final SchemaRegistry schemaRegistry;
    private final LinkedHashSet<URI> dynamicScope;
    private boolean trackEvaluatedItems;
    private boolean trackEvaluatedProperties;
    private final boolean formatAnnotation;

    public EvaluationContext() {
        this(null, "", "", null, new LinkedHashSet<>());
    }

    public EvaluationContext(SchemaRegistry schemaRegistry) {
        this(null, "", "", schemaRegistry, new LinkedHashSet<>());
    }

    private EvaluationContext(EvaluationContext parent, String instanceLocationSegment, String schemaLocationSegment,
                              SchemaRegistry schemaRegistry, LinkedHashSet<URI> dynamicScope) {
        this.parent = parent;
        this.instanceLocationSegment = instanceLocationSegment == null ? "" : instanceLocationSegment;
        this.schemaLocationSegment = schemaLocationSegment == null ? "" : schemaLocationSegment;
        this.instanceLocation = null;
        this.schemaLocation = null;
        this.errors = parent != null ? parent.errors : new ArrayList<>();
        this.annotations = null;
        this.schemaRegistry = schemaRegistry;
        this.dynamicScope = dynamicScope;
        this.trackEvaluatedItems = parent != null && parent.trackEvaluatedItems;
        this.trackEvaluatedProperties = parent != null && parent.trackEvaluatedProperties;
        this.formatAnnotation = parent == null || parent.formatAnnotation;
    }

    public void pushDynamicScope(URI resourceUri) {
        dynamicScope.add(resourceUri);
    }

    public void popDynamicScope() {
        if (!dynamicScope.isEmpty()) {
            dynamicScope.removeLast();
        }
    }

    public LinkedHashSet<URI> getDynamicScope() {
        return dynamicScope;
    }

    public EvaluationContext createChildContext(String instancePathSegment, String schemaPathSegment) {
        return new EvaluationContext(this, instancePathSegment, schemaPathSegment, schemaRegistry,
                new LinkedHashSet<>(this.dynamicScope));
    }

    public void addError(String keywordName, String message) {
        errors.add(message);
    }

    public List<String> getErrors() {
        return errors;
    }

    public void setAnnotation(String keywordName, Object value) {
        if (annotations == null) {
            annotations = new HashMap<>();
        }
        annotations.put(keywordName, value);
    }

    public Object getAnnotation(String keywordName) {
        return annotations == null ? null : annotations.get(keywordName);
    }

    public String getInstanceLocation() {
        if (instanceLocation == null) {
            instanceLocation = resolveLocation(instanceLocationSegment, true);
        }
        return instanceLocation;
    }

    public String getSchemaLocation() {
        if (schemaLocation == null) {
            schemaLocation = resolveLocation(schemaLocationSegment, false);
        }
        return schemaLocation;
    }

    private String resolveLocation(String segment, boolean instancePath) {
        if (parent == null) {
            return segment;
        }

        String parentLocation = instancePath ? parent.getInstanceLocation() : parent.getSchemaLocation();
        if (segment.isEmpty()) {
            return parentLocation;
        }
        if (parentLocation.isEmpty()) {
            return segment;
        }
        return parentLocation + "/" + segment;
    }

    public SchemaRegistry getSchemaRegistry() {
        return schemaRegistry;
    }

    public boolean isTrackEvaluatedItems() {
        return trackEvaluatedItems;
    }

    public void setTrackEvaluatedItems(boolean trackEvaluatedItems) {
        this.trackEvaluatedItems = trackEvaluatedItems;
    }

    public boolean isTrackEvaluatedProperties() {
        return trackEvaluatedProperties;
    }

    public void setTrackEvaluatedProperties(boolean trackEvaluatedProperties) {
        this.trackEvaluatedProperties = trackEvaluatedProperties;
    }

    public boolean isFormatAnnotation() {
        return formatAnnotation;
    }

    public void moveToParentContext(String annotationKey) {
        if (parent == null || annotations == null) {
            return;
        }

        Object annotationValue = annotations.get(annotationKey);
        if (annotationValue == null) {
            return;
        }
        Object parentAnnotationValue = parent.getAnnotation(annotationKey);
        if (parentAnnotationValue == null) {
            parent.setAnnotation(annotationKey, annotationValue);
            return;
        }

        if (annotationValue instanceof Boolean childBool) {
            if (childBool) {
                parent.setAnnotation(annotationKey, true);
            }
            return;
        }

        if (parentAnnotationValue instanceof Boolean parentBool) {
            if (!parentBool) {
                parent.setAnnotation(annotationKey, annotationValue);
            }
            return;
        }

        if (annotationValue instanceof List<?> childAnnotationValues
                && parentAnnotationValue instanceof List<?> parentAnnotationValues) {
            List<Object> parentList = (List<Object>) parentAnnotationValues;
            for (Object value : childAnnotationValues) {
                if (!parentList.contains(value)) {
                    parentList.add(value);
                }
            }
            return;
        }

        if (annotationValue instanceof Set<?> childAnnotationValues
                && parentAnnotationValue instanceof Set<?> parentAnnotationValues) {
            Set<Object> parentSet = (Set<Object>) parentAnnotationValues;
            parentSet.addAll(childAnnotationValues);
        }
    }
}
