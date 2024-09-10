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

#ifndef LOTTIE_SRC_MAIN_CPP_EVENTEMITTERS_H
#define LOTTIE_SRC_MAIN_CPP_EVENTEMITTERS_H

#include <react/renderer/components/view/ViewEventEmitter.h>
#include <jsi/jsi.h>

namespace facebook {
namespace react {

class JSI_EXPORT LottieAnimationViewEventEmitter : public ViewEventEmitter {
public:
    using ViewEventEmitter::ViewEventEmitter;

    struct OnAnimationFinish {
        bool isCancelled;
    };

    struct OnAnimationFailure {
        std::string error;
    };

    void onAnimationFinish(OnAnimationFinish value) const;
    void onAnimationLoaded() const;
    void onAnimationFailure(OnAnimationFailure value) const;
};

} // namespace react
} // namespace facebook

#endif 