# Tests for jboss/container/jolokia
Feature: Openshift OpenJDK Jolokia tests

  @openj9
  Scenario: Check Environment variable is correct
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
    Then run sh -c 'unzip -q -p /usr/share/java/jolokia-jvm-agent/jolokia-jvm.jar META-INF/maven/org.jolokia/jolokia-jvm/pom.properties | grep -F ${JOLOKIA_VERSION}' in container and check its output for version=

  @openjdk
  @ubi8/openjdk-8
  @ubi8/openjdk-11
  @redhat-openjdk-18
  Scenario: Check jolokia port is available
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
    Then check that port 8778 is open
    And  inspect container
       | path                    | value       |
       | /Config/ExposedPorts    | 8778/tcp    |

  @openjdk
  @ubi8/openjdk-8
  @ubi8/openjdk-11
  @redhat-openjdk-18
  Scenario: Ensure Jolokia diagnostic options work correctly
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable         | value               |
       | JAVA_ARGS        | Hello from CTF test |
       | JAVA_DIAGNOSTICS | true                |
    Then container log should contain /deployments/undertow-servlet.jar Hello from CTF test
      And container log should contain Jolokia: Agent started

  @redhat-openjdk-18
  @openjdk
  Scenario: Ensure the Jolokia Agent JAR has the expected checksum
    When container is started with args
    | arg     | value                                                        |
    | command | bash -c "md5sum $JBOSS_CONTAINER_JOLOKIA_MODULE/jolokia.jar" |
    Then available container log should contain 760f2fbaf6b142192f3cee2c99bfcbf8
