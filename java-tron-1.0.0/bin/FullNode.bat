@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  FullNode startup script for Windows tron
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Add default JVM options here. You can also use JAVA_OPTS and FULL_NODE_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windows variants

if not "%OS%" == "Windows_NT" goto win9xME_args

:win9xME_args
@rem Slurp the command line arguments.
set CMD_LINE_ARGS=
set _SKIP=2

:win9xME_args_slurp
if "x%~1" == "x" goto execute

set CMD_LINE_ARGS=%*

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\framework-1.0.0.jar;%APP_HOME%\lib\actuator-1.0.0.jar;%APP_HOME%\lib\consensus-1.0.0.jar;%APP_HOME%\lib\chainbase-1.0.0.jar;%APP_HOME%\lib\crypto-1.0.0.jar;%APP_HOME%\lib\common-1.0.0.jar;%APP_HOME%\lib\protocol-1.0.0.jar;%APP_HOME%\lib\jcl-over-slf4j-1.7.25.jar;%APP_HOME%\lib\libp2p-2.2.5.jar;%APP_HOME%\lib\logback-classic-1.2.13.jar;%APP_HOME%\lib\metrics-core-3.1.2.jar;%APP_HOME%\lib\metrics-influxdb-0.8.2.jar;%APP_HOME%\lib\jsonrpc4j-1.6.jar;%APP_HOME%\lib\dnsjava-3.6.2.jar;%APP_HOME%\lib\crypto-5.0.0.jar;%APP_HOME%\lib\route53-2.18.41.jar;%APP_HOME%\lib\aws-xml-protocol-2.18.41.jar;%APP_HOME%\lib\aws-query-protocol-2.18.41.jar;%APP_HOME%\lib\protocol-core-2.18.41.jar;%APP_HOME%\lib\aws-core-2.18.41.jar;%APP_HOME%\lib\auth-2.18.41.jar;%APP_HOME%\lib\regions-2.18.41.jar;%APP_HOME%\lib\sdk-core-2.18.41.jar;%APP_HOME%\lib\apache-client-2.18.41.jar;%APP_HOME%\lib\netty-nio-client-2.18.41.jar;%APP_HOME%\lib\http-client-spi-2.18.41.jar;%APP_HOME%\lib\metrics-spi-2.18.41.jar;%APP_HOME%\lib\json-utils-2.18.41.jar;%APP_HOME%\lib\profiles-2.18.41.jar;%APP_HOME%\lib\utils-2.18.41.jar;%APP_HOME%\lib\alidns20150109-3.0.1.jar;%APP_HOME%\lib\tea-openapi-0.2.8.jar;%APP_HOME%\lib\alibabacloud-gateway-spi-0.0.1.jar;%APP_HOME%\lib\tea-rpc-0.1.2.jar;%APP_HOME%\lib\credentials-java-0.2.4.jar;%APP_HOME%\lib\tea-1.2.0.jar;%APP_HOME%\lib\slf4j-api-1.7.36.jar;%APP_HOME%\lib\grpc-services-1.60.0.jar;%APP_HOME%\lib\protobuf-java-util-3.25.5.jar;%APP_HOME%\lib\grpc-protobuf-1.60.0.jar;%APP_HOME%\lib\guice-4.1.0.jar;%APP_HOME%\lib\reflections-0.9.11.jar;%APP_HOME%\lib\grpc-netty-1.60.0.jar;%APP_HOME%\lib\grpc-stub-1.60.0.jar;%APP_HOME%\lib\grpc-core-1.60.0.jar;%APP_HOME%\lib\grpc-protobuf-lite-1.60.0.jar;%APP_HOME%\lib\grpc-context-1.60.0.jar;%APP_HOME%\lib\grpc-api-1.60.0.jar;%APP_HOME%\lib\grpc-util-1.60.0.jar;%APP_HOME%\lib\guava-32.0.1-jre.jar;%APP_HOME%\lib\jsr305-3.0.2.jar;%APP_HOME%\lib\spring-context-5.3.18.jar;%APP_HOME%\lib\spring-tx-5.3.18.jar;%APP_HOME%\lib\commons-lang3-3.4.jar;%APP_HOME%\lib\commons-math-2.2.jar;%APP_HOME%\lib\commons-collections4-4.1.jar;%APP_HOME%\lib\joda-time-2.3.jar;%APP_HOME%\lib\bcprov-jdk15on-1.69.jar;%APP_HOME%\lib\java-sizeof-0.0.5.jar;%APP_HOME%\lib\jetty-servlet-9.4.53.v20231009.jar;%APP_HOME%\lib\jetty-security-9.4.53.v20231009.jar;%APP_HOME%\lib\jetty-server-9.4.53.v20231009.jar;%APP_HOME%\lib\fastjson-1.2.83.jar;%APP_HOME%\lib\vavr-0.9.2.jar;%APP_HOME%\lib\pf4j-3.10.0.jar;%APP_HOME%\lib\jeromq-0.5.3.jar;%APP_HOME%\lib\jansi-1.16.jar;%APP_HOME%\lib\zksnark-java-sdk-1.0.0.jar;%APP_HOME%\lib\proto-google-common-protos-2.22.0.jar;%APP_HOME%\lib\protobuf-java-3.25.5.jar;%APP_HOME%\lib\jcip-annotations-1.0.jar;%APP_HOME%\lib\logback-core-1.2.13.jar;%APP_HOME%\lib\spring-aop-5.3.18.jar;%APP_HOME%\lib\spring-beans-5.3.18.jar;%APP_HOME%\lib\spring-expression-5.3.18.jar;%APP_HOME%\lib\spring-core-5.3.18.jar;%APP_HOME%\lib\javax.inject-1.jar;%APP_HOME%\lib\aopalliance-1.0.jar;%APP_HOME%\lib\javax.servlet-api-3.1.0.jar;%APP_HOME%\lib\jetty-http-9.4.53.v20231009.jar;%APP_HOME%\lib\jetty-io-9.4.53.v20231009.jar;%APP_HOME%\lib\jetty-util-ajax-9.4.53.v20231009.jar;%APP_HOME%\lib\base64-2.3.9.jar;%APP_HOME%\lib\jackson-annotations-2.13.4.jar;%APP_HOME%\lib\jackson-databind-2.13.4.2.jar;%APP_HOME%\lib\jackson-core-2.13.4.jar;%APP_HOME%\lib\openapiutil-0.2.0.jar;%APP_HOME%\lib\httpasyncclient-4.1.1.jar;%APP_HOME%\lib\httpclient-4.5.13.jar;%APP_HOME%\lib\commons-codec-1.15.jar;%APP_HOME%\lib\httpcore-nio-4.4.5.jar;%APP_HOME%\lib\vavr-match-0.9.2.jar;%APP_HOME%\lib\java-semver-0.9.0.jar;%APP_HOME%\lib\jnacl-1.0.0.jar;%APP_HOME%\lib\java-util-1.8.0.jar;%APP_HOME%\lib\jcommander-1.78.jar;%APP_HOME%\lib\config-1.3.2.jar;%APP_HOME%\lib\leveldbjni-all-1.8.jar;%APP_HOME%\lib\rocksdbjni-5.15.10.jar;%APP_HOME%\lib\simpleclient_httpserver-0.15.0.jar;%APP_HOME%\lib\simpleclient_hotspot-0.15.0.jar;%APP_HOME%\lib\simpleclient_common-0.15.0.jar;%APP_HOME%\lib\simpleclient-0.15.0.jar;%APP_HOME%\lib\aspectjrt-1.8.13.jar;%APP_HOME%\lib\aspectjweaver-1.8.13.jar;%APP_HOME%\lib\aspectjtools-1.8.13.jar;%APP_HOME%\lib\hawtjni-runtime-1.18.jar;%APP_HOME%\lib\commons-io-2.11.0.jar;%APP_HOME%\lib\javassist-3.21.0-GA.jar;%APP_HOME%\lib\tea-util-0.2.16.jar;%APP_HOME%\lib\tea-rpc-util-0.1.3.jar;%APP_HOME%\lib\gson-2.10.1.jar;%APP_HOME%\lib\error_prone_annotations-2.20.0.jar;%APP_HOME%\lib\j2objc-annotations-2.8.jar;%APP_HOME%\lib\netty-codec-http2-4.1.100.Final.jar;%APP_HOME%\lib\netty-handler-proxy-4.1.100.Final.jar;%APP_HOME%\lib\perfmark-api-0.26.0.jar;%APP_HOME%\lib\netty-codec-http-4.1.100.Final.jar;%APP_HOME%\lib\netty-handler-4.1.100.Final.jar;%APP_HOME%\lib\netty-transport-native-unix-common-4.1.100.Final.jar;%APP_HOME%\lib\spring-jcl-5.3.18.jar;%APP_HOME%\lib\jetty-util-9.4.53.v20231009.jar;%APP_HOME%\lib\httpcore-4.4.13.jar;%APP_HOME%\lib\commons-logging-1.2.jar;%APP_HOME%\lib\json-io-2.4.1.jar;%APP_HOME%\lib\simpleclient_tracer_otel-0.15.0.jar;%APP_HOME%\lib\simpleclient_tracer_otel_agent-0.15.0.jar;%APP_HOME%\lib\snappy-java-1.1.10.5.jar;%APP_HOME%\lib\bcpkix-jdk18on-1.79.jar;%APP_HOME%\lib\commons-cli-1.5.0.jar;%APP_HOME%\lib\failureaccess-1.0.1.jar;%APP_HOME%\lib\listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar;%APP_HOME%\lib\checker-qual-3.33.0.jar;%APP_HOME%\lib\annotations-4.1.1.4.jar;%APP_HOME%\lib\animal-sniffer-annotations-1.23.jar;%APP_HOME%\lib\netty-codec-socks-4.1.100.Final.jar;%APP_HOME%\lib\netty-codec-4.1.100.Final.jar;%APP_HOME%\lib\netty-transport-4.1.100.Final.jar;%APP_HOME%\lib\netty-buffer-4.1.100.Final.jar;%APP_HOME%\lib\netty-resolver-4.1.100.Final.jar;%APP_HOME%\lib\netty-common-4.1.100.Final.jar;%APP_HOME%\lib\simpleclient_tracer_common-0.15.0.jar;%APP_HOME%\lib\abi-5.0.0.jar;%APP_HOME%\lib\rlp-5.0.0.jar;%APP_HOME%\lib\utils-5.0.0.jar;%APP_HOME%\lib\endpoints-spi-2.18.41.jar;%APP_HOME%\lib\annotations-2.18.41.jar;%APP_HOME%\lib\endpoint-util-0.0.7.jar;%APP_HOME%\lib\reactive-streams-1.0.3.jar;%APP_HOME%\lib\eventstream-1.0.1.jar;%APP_HOME%\lib\third-party-jackson-core-2.18.41.jar;%APP_HOME%\lib\okhttp-3.12.13.jar;%APP_HOME%\lib\org.jacoco.agent-0.8.4-runtime.jar;%APP_HOME%\lib\tea-xml-0.1.5.jar;%APP_HOME%\lib\dom4j-2.1.3.jar;%APP_HOME%\lib\jaxb-api-2.3.0.jar;%APP_HOME%\lib\jaxb-core-2.3.0.jar;%APP_HOME%\lib\jaxb-impl-2.3.0.jar;%APP_HOME%\lib\ini4j-0.5.4.jar;%APP_HOME%\lib\okio-1.15.0.jar

@rem Execute FullNode
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %FULL_NODE_OPTS%  -classpath "%CLASSPATH%" org.tron.program.FullNode %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable FULL_NODE_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%FULL_NODE_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
