/**
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

#ifndef LOTTIE_SRC_MAIN_CPP_COMPONENTDESCRIPTOR_H
#define LOTTIE_SRC_MAIN_CPP_COMPONENTDESCRIPTOR_H

#include <react/renderer/core/ConcreteComponentDescriptor.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>
#include "Props.h"
#include "EventEmitters.h"

namespace facebook {
namespace react {

extern const char LOTTIE_ANIMATION_VIEW_COMPONENT_NAME[] = "LottieAnimationView";

using LottieAnimationViewShadowNode = ConcreteViewShadowNode<LOTTIE_ANIMATION_VIEW_COMPONENT_NAME,
                                                             LottieAnimationViewProps, LottieAnimationViewEventEmitter>;

using LottieAnimationViewComponentDescriptor = ConcreteComponentDescriptor<LottieAnimationViewShadowNode>;

} // namespace react
} // namespace facebook

#endif