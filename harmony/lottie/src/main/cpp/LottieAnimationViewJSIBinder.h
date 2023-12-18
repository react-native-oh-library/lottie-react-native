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

#ifndef LOTTIE_SRC_MAIN_CPP_LOTTIEANIMATIONVIEWJSIBINDER_H
#define LOTTIE_SRC_MAIN_CPP_LOTTIEANIMATIONVIEWJSIBINDER_H

#include "RNOHCorePackage/ComponentBinders/ViewComponentJSIBinder.h"

namespace rnoh {
class LottieAnimationViewJSIBinder : public ViewComponentJSIBinder{
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override
    {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "resizeMode", "string");
        object.setProperty(rt, "renderMode", "string");
        object.setProperty(rt, "sourceName", "string");
        object.setProperty(rt, "sourceJson", "string");
        object.setProperty(rt, "sourceURL", "string");
        object.setProperty(rt, "imageAssetsFolder", "string");
        object.setProperty(rt, "progress", "float");
        object.setProperty(rt, "speed", "double");
        object.setProperty(rt, "loop", "boolean");
        object.setProperty(rt, "autoPlay", "boolean");
        object.setProperty(rt, "enableMergePathsAndroidForKitKatAndAbove", "boolean");
        object.setProperty(rt, "hardwareAccelerationAndroid", "boolean");
        object.setProperty(rt, "cacheComposition", "boolean");
        return object;
    }

    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override
    {
        return facebook::jsi::Object(rt);
    }

    facebook::jsi::Object createDirectEventTypes(facebook::jsi::Runtime &rt) override
    {
        facebook::jsi::Object events(rt);
        events.setProperty(rt, "topAnimationFinish", createDirectEvent(rt, "onAnimationFinish"));
        return events;
    }
};
} //namespace rnoh

#endif
