// Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
// Use of this source code is governed by a Apache-2.0 license that can be
// found in the LICENSE file.

import { RNPackage } from '@rnoh/react-native-openharmony/ts';
import type {DescriptorWrapperFactoryByDescriptorTypeCtx, DescriptorWrapperFactoryByDescriptorType} from '@rnoh/react-native-openharmony/ts';
import { RNC } from './generated/ts';

export class LottieAnimationViewPackage extends RNPackage {
  createDescriptorWrapperFactoryByDescriptorType(ctx:
          DescriptorWrapperFactoryByDescriptorTypeCtx):
          DescriptorWrapperFactoryByDescriptorType {
    return {
      [RNC.LottieAnimationView.NAME]: (ctx) => new RNC.LottieAnimationView.DescriptorWrapper(ctx.descriptor)
    }
  }
}