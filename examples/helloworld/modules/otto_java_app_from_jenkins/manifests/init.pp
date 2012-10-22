define otto_java_app_from_jenkins($appName = $title, $jenkinsProjectName, $jenkinsBuildID, $appUserGroupName, $appConfSource, $appRunContent) {
  include java

  $appBuildID = "${jenkinsProjectName}@${jenkinsBuildID}"
  $appBuildArtifactName = "${appName}-assembly-1.0.jar"
  $appBuildArtifactTempName = "${appBuildArtifactName}.tmp"
  $appBuildArtifactUrl = "https://spindle-app-dev-otto-examples.s3-us-west-2.amazonaws.com/job/${jenkinsProjectName}/${jenkinsBuildID}/artifact/${appName}/target/${appBuildArtifactName}"

  otto::app { $appName:
    appBuildID => $appBuildID,
    appUserGroupName => $appUserGroupName,
    # If your build server requires authentication, see:
    # https://wiki.jenkins-ci.org/display/JENKINS/Authenticating+scripted+clients
    appBuildArtifactFetchCommand => sprintf("/bin/sh -c 'umask 077 && wget -O %s %s && chgrp %s %s && chmod 0640 %s && mv %s %s'",
                                            shellquote($appBuildArtifactTempName),
                                            shellquote($appBuildArtifactUrl),
                                            shellquote($appUserGroupName),
                                            shellquote($appBuildArtifactTempName),
                                            shellquote($appBuildArtifactTempName),
                                            shellquote($appBuildArtifactTempName),
                                            shellquote($appBuildArtifactName)),
    appBuildArtifactName => $appBuildArtifactName,
    appConfSource => $appConfSource,
    appRunContent => $appRunContent,
    require => [Class["java"], User[$appUserGroupName]]
  }
}