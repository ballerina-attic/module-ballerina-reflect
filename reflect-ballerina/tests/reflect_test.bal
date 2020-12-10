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
import ballerina/config;

const string MODULE_NAME = "ballerina/reflect";

public class Listener {
    boolean initialized = false;
    boolean started = false;

    public isolated function 'start() returns error? {
        self.started = true;
        return ();
    }
    public isolated function gracefulStop() returns error? {
    }
    public isolated function immediateStop() returns error? {
    }
    public isolated function detach(service object {} s) returns error? {
    }
    public isolated function attach(service object {} s, string[]|string? name = ()) returns error? {
    }
    isolated function register(service object {} s, string[]|string? name) returns error? {
    }

    public function init() {
        self.initialized = true;
    }
}

listener Listener lis = new();

type Annotation record {
    string foo;
    int bar?;
};

annotation Annotation serviceAnnotation on service;
annotation Annotation resourceAnnotation on function;

string serviceAnnotationValue = "serviceAnnotation";
string resourceAnnotationValue = "resourceAnnotation";

type S service object {
    resource function get processRequest() returns json;
};

service object {} ser = @serviceAnnotation{foo: serviceAnnotationValue}
service object {
    @resourceAnnotation{foo: resourceAnnotationValue}
    resource function get processRequest() returns json {
        return { output: "Hello" };
    }
};

public function attachService() {
    _ = <any> lis.attach(ser, "/");
}

@test:Config {
    before: "attachService"
}
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

@test:Config {}
public function testResourceAnnotations() {
    string moduleNameWithVersion = MODULE_NAME + COLON + config:getAsString("STDLIB_VERSION");
    Annotation? annot = <Annotation?> getResourceAnnotations(ser, "processRequest", resourceAnnotationValue, moduleNameWithVersion);
    boolean isExpectedAnnotation = false;
    if (annot is Annotation && resourceAnnotationValue == annot.foo) {
        isExpectedAnnotation = true;
    }
    test:assertTrue(isExpectedAnnotation, "Returned annotation mismatch");
}
