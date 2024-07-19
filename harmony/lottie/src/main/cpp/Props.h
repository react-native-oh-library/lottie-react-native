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

#ifndef LOTTIE_SRC_MAIN_CPP_PROPS_H
#define LOTTIE_SRC_MAIN_CPP_PROPS_H

#include <jsi/jsi.h>
#include <react/renderer/components/view/ViewProps.h>
#include <react/renderer/core/PropsParserContext.h>
#include <react/renderer/core/propsConversions.h>

namespace facebook {
namespace react {

class JSI_EXPORT LottieAnimationViewProps final : public ViewProps {
public:
    LottieAnimationViewProps() = default;
    LottieAnimationViewProps(const PropsParserContext &context, const LottieAnimationViewProps &sourceProps,
                             const RawProps &rawProps);

#pragma mark - Props

    std::string resizeMode{};
    std::string renderMode{};
    std::string sourceName{};
    std::string sourceJson{};
    std::string sourceURL{};
    std::string imageAssetsFolder{};
    std::string colorFilters{};
    Float progress{0.0};
    Float speed{1.0};
    bool loop{true};
    bool autoPlay{false};
    bool enableMergePathsAndroidForKitKatAndAbove{false};
    bool hardwareAccelerationAndroid{false};
    bool cacheComposition{true};
};

} // namespace react
} // namespace facebook

#endif 