/*
 * Copyright (C) 2023 Huawei Device Co., Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * you may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <react/renderer/core/PropsParserContext.h>
#include <react/renderer/core/propsConversions.h>
#include "Props.h"

namespace facebook {
namespace react {

LottieAnimationViewProps::LottieAnimationViewProps(const PropsParserContext &context,
                                                   const LottieAnimationViewProps &sourceProps,
                                                   const RawProps &rawProps)      
    : ViewProps(context, sourceProps, rawProps),
    resizeMode(convertRawProp(context, rawProps, "resizeMode", sourceProps.resizeMode, {})),
    renderMode(convertRawProp(context, rawProps, "renderMode", sourceProps.renderMode, {})),
    sourceName(convertRawProp(context, rawProps, "sourceName", sourceProps.sourceName, {})),
    sourceJson(convertRawProp(context, rawProps, "sourceJson", sourceProps.sourceJson, {})),
    sourceURL(convertRawProp(context, rawProps, "sourceURL", sourceProps.sourceURL, {})),
    imageAssetsFolder(convertRawProp(context, rawProps, "imageAssetsFolder", sourceProps.imageAssetsFolder, {})),
    progress(convertRawProp(context, rawProps, "progress", sourceProps.progress, {0.0})),
    speed(convertRawProp(context, rawProps, "speed", sourceProps.speed, {1.0})),
    loop(convertRawProp(context, rawProps, "loop", sourceProps.loop, {true})),
    autoPlay(convertRawProp(context, rawProps, "autoPlay", sourceProps.autoPlay, {false})),
    enableMergePathsAndroidForKitKatAndAbove(
        convertRawProp(context, rawProps, "enableMergePathsAndroidForKitKatAndAbove",
                       sourceProps.enableMergePathsAndroidForKitKatAndAbove, {false})),
    hardwareAccelerationAndroid(convertRawProp(context, rawProps, "hardwareAccelerationAndroid",
                                               sourceProps.hardwareAccelerationAndroid, {false})),
    cacheComposition(convertRawProp(context, rawProps, "cacheComposition", sourceProps.cacheComposition, {true})),
    colorFilters(convertRawProp(context, rawProps, "colorFilters", sourceProps.colorFilters, {}))
    {}
} // namespace react
} // namespace facebook
