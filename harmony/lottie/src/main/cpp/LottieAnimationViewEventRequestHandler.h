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

#ifndef LOTTIE_SRC_MAIN_CPP_LOTTIEANIMATIONVIEWEVENTREQUESTHANDLER_H
#define LOTTIE_SRC_MAIN_CPP_LOTTIEANIMATIONVIEWEVENTREQUESTHANDLER_H

#include <napi/native_api.h>
#include "RNOH/ArkJS.h"
#include "RNOH/EventEmitRequestHandler.h"
#include "EventEmitters.h"

using namespace facebook;
namespace rnoh {

enum class LottieAnimationViewEventType { LOTTIE_ANIMATION_FINISH = 0, LOTTIE_ANIMATION_LOADED= 1, LOTTIE_ANIMATION_FAILURE=2 };

LottieAnimationViewEventType getLottieEventType(ArkJS &arkJs, napi_value eventObject)
{
    auto eventType = arkJs.getString(arkJs.getObjectProperty(eventObject, "type"));
    if (eventType == "onAnimationFinish") {
        return LottieAnimationViewEventType::LOTTIE_ANIMATION_FINISH;
    } else if (eventType == "onAnimationLoaded") {
         return LottieAnimationViewEventType::LOTTIE_ANIMATION_LOADED;
    } else if (eventType == "onAnimationFailure") {
        return LottieAnimationViewEventType::LOTTIE_ANIMATION_FAILURE;
    } else {
        throw std::runtime_error("Unknown Page event type");
    }
}

class LottieAnimationViewEventRequestHandler : public EventEmitRequestHandler {
public:
    void handleEvent(EventEmitRequestHandler::Context const &ctx) override
    {
        if (ctx.eventName != "LottieAnimationView") {
            return;
        }
        ArkJS arkJs(ctx.env);
        auto eventEmitter = ctx.shadowViewRegistry->getEventEmitter<react::LottieAnimationViewEventEmitter>(ctx.tag);
        if (eventEmitter == nullptr) {
            return;
        }
        
        switch (getLottieEventType(arkJs, ctx.payload)) {
            case LottieAnimationViewEventType::LOTTIE_ANIMATION_FINISH: {
                bool isCancelled = arkJs.getBoolean(arkJs.getObjectProperty(ctx.payload, "isCancelled"));
                react::LottieAnimationViewEventEmitter::OnAnimationFinish event{isCancelled};
                eventEmitter->onAnimationFinish(event);
                break;
            }
             case LottieAnimationViewEventType::LOTTIE_ANIMATION_LOADED: {
                eventEmitter->onAnimationLoaded();
                break;
            }
             case LottieAnimationViewEventType::LOTTIE_ANIMATION_FAILURE: {
                std::string error = arkJs.getString (arkJs.getObjectProperty(ctx.payload, "error"));
                react::LottieAnimationViewEventEmitter::OnAnimationFailure event{error};
                eventEmitter->onAnimationFailure(event);
                break;
            }
            default:
                break;
        }

    };
};
} // namespace rnoh

#endif 
