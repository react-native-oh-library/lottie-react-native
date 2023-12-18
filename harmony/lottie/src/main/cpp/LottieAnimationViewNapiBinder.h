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
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KING, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef LOTTIE_SRC_MAIN_CPP_LOTTIEANIMATIONVIEWNAPIBINDER_H
#define LOTTIE_SRC_MAIN_CPP_LOTTIEANIMATIONVIEWNAPIBINDER_H

#include "RNOHCorePackage/ComponentBinders/ViewComponentNapiBinder.h"
#include "RNOH/ArkJS.h"
#include "Props.h"

namespace rnoh {

class LottieAnimationViewNapiBinder : public ViewComponentNapiBinder{
public:
    napi_value createProps(napi_env env, facebook::react::ShadowView const shadowView) override
    {
        napi_value napiViewProps = ViewComponentNapiBinder::createProps(env, shadowView);
        if (auto props = std::dynamic_pointer_cast<const facebook::react::LottieAnimationViewProps>(shadowView.props)){
            return ArkJS(env)
                .getObjectBuilder(napiViewProps)
                .addProperty("resizeMode", props->resizeMode)
                .addProperty("renderMode", props->renderMode)
                .addProperty("sourceName", props->sourceName)
                .addProperty("sourceJson", props->sourceJson)
                .addProperty("sourceURL", props->sourceURL)
                .addProperty("imageAssetsFolder", props->imageAssetsFolder)
                .addProperty("progress", props->progress)
                .addProperty("speed", props->speed)
                .addProperty("loop", props->loop)
                .addProperty("autoPlay", props->autoPlay)
                .addProperty("enableMergePathsAndroidForKitKatAndAbove",
                             props->enableMergePathsAndroidForKitKatAndAbove)
                .addProperty("hardwareAccelerationAndroid", props->hardwareAccelerationAndroid)
                .addProperty("cacheComposition", props->cacheComposition)
                .build();
        }
        return napiViewProps;
    };
};

} // namespace rnoh

#endif 
