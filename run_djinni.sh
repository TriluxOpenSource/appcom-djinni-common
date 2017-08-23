#! /usr/bin/env bash

declare base_dir=$(cd "`dirname "0"`" && pwd)
declare cpp_out="$base_dir/generated-src/cpp"
declare jni_out="$base_dir/generated-src/jni"
declare objc_out="$base_dir/generated-src/objc"
declare objcpp_out="$base_dir/generated-src/objcpp"
declare java_out="$base_dir/generated-src/java/eu/appcom/microservices/sdk/common"
declare java_package="eu.appcom.microservices.sdk.common"
declare namespace="appcom"
declare objc_prefix="AC"
declare djinni_file="ac_ms_common_sdk.djinni"
declare yaml_out="output"
declare yaml_out_file="ac_ms_common_sdk.yml"

rm -r $base_dir/generated-src/*

deps/djinni/src/run \
   --java-out $java_out \
   --java-package $java_package \
   --ident-java-field mFooBar \
   \
   --cpp-out $cpp_out \
   --cpp-namespace $namespace \
   --cpp-optional-template "boost::optional" \
   --cpp-optional-header "<boost/optional.hpp>" \
   \
   --jni-out $jni_out \
   --ident-jni-class NativeFooBar \
   --ident-jni-file NativeFooBar \
   \
   --objc-out $objc_out \
   --objc-type-prefix $objc_prefix \
   \
   --objcpp-out $objcpp_out \
   \
   --idl $djinni_file \
   \
   --yaml-out $yaml_out \
   --yaml-out-file $yaml_out_file
