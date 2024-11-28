// Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
// Use of this source code is governed by a Apache-2.0 license that can be
// found in the LICENSE file.

import HashMap from '@ohos.util.HashMap'
import { AnimationObject } from './common/Animation'

export class LottieCompositionCache {
  private static readonly sInstance: LottieCompositionCache = new LottieCompositionCache()
  private cache: HashMap<String, AnimationObject> = new HashMap()

  public static getInstance(): LottieCompositionCache {
    return LottieCompositionCache.sInstance
  }

  get(cacheKey: string): AnimationObject | null {
    return cacheKey ? this.cache.get(cacheKey) : null
  }

  set(cacheKey: string, composition: AnimationObject): void {
    if (cacheKey.length === 0) {
      return
    }
    this.cache.set(cacheKey, composition)
  }

  clear(): void {
    this.cache.clear()
  }
}