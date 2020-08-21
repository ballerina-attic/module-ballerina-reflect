// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;
import ballerina/lang.'object as lang;
import ballerina/config;

const string MODULE_NAME = "ballerina/reflect";

type Listener object {
    *lang:Listener;

    public function init() {
    }

    public function __attach(service s, string? name = ()) returns error? {
    }

    public function __detach(service s) returns error? {
    }

    public function __start() returns error? {
    }

    public function __gracefulStop() returns error? {
        return ();
    }

    public function __immediateStop() returns error? {
        return ();
    }
};

listener Listener lis = new();

type Annotation record {
    string foo;
    int bar?;
};

annotation Annotation serviceAnnotation on service;
annotation Annotation resourceAnnotation on function;

string serviceAnnotationValue = "serviceAnnotation";
string resourceAnnotationValue = "resourceAnnotation";

@serviceAnnotation{foo: serviceAnnotationValue}
service ser on lis {
    @resourceAnnotation{foo: resourceAnnotationValue}
    resource function res() {
    }
}

@test:Config {}
public function testServiceAnnotation() {
    string annotationName = MODULE_NAME + COLON + config:getAsString("STDLIB_VERSION") +
                            COLON + serviceAnnotationValue;
    Annotation? annot = <Annotation?> getServiceAnnotations(ser, annotationName);
    boolean isExpectedAnnotation = false;
    if (annot is Annotation && serviceAnnotationValue == annot.foo) {
        isExpectedAnnotation = true;
    }
    test:assertTrue(isExpectedAnnotation, "Returned annotation mismatch");
}

@test:Config {
    dependsOn: ["testServiceAnnotation"]
}
public function testServiceAnnotationWitSeparateModuleName() {
    string moduleNameWithVersion = MODULE_NAME + COLON + config:getAsString("STDLIB_VERSION");
    Annotation? annot = <Annotation?> getServiceAnnotations(ser, serviceAnnotationValue,
                                                            moduleNameWithVersion);
    boolean isExpectedAnnotation = false;
    if (annot is Annotation && serviceAnnotationValue == annot.foo) {
        isExpectedAnnotation = true;
    }
    test:assertTrue(isExpectedAnnotation, "Returned annotation mismatch");
}

@test:Config {
    dependsOn: ["testServiceAnnotationWitSeparateModuleName"]
}
public function testResourceAnnotations() {
    string moduleNameWithVersion = MODULE_NAME + COLON + config:getAsString("STDLIB_VERSION");
    Annotation? annot = <Annotation?> getResourceAnnotations(ser, "res", resourceAnnotationValue, moduleNameWithVersion);
    boolean isExpectedAnnotation = false;
    if (annot is Annotation && resourceAnnotationValue == annot.foo) {
        isExpectedAnnotation = true;
    }
    test:assertTrue(isExpectedAnnotation, "Returned annotation mismatch");
}
