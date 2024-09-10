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

#include "EventEmitters.h"

namespace facebook {
namespace react {

void LottieAnimationViewEventEmitter::onAnimationFinish(OnAnimationFinish event) const
{
    dispatchEvent("animationFinish",[event = std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime, "isCancelled", event.isCancelled);
		return payload;
    });
}

void LottieAnimationViewEventEmitter::onAnimationLoaded() const
{
    dispatchEvent("animationLoaded",[](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
		return payload;
    });
}

void LottieAnimationViewEventEmitter::onAnimationFailure(OnAnimationFailure event) const
{
    dispatchEvent("animationFailure",[event = std::move(event)](jsi::Runtime &runtime){
        auto payload = jsi::Object(runtime);
        payload.setProperty(runtime, "error", event.error);
		return payload;
    });
}

} // namespace react
} // namespace facebook

