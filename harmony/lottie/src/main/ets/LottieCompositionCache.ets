/*
 * Copyright (C) 2023 Huawei Device Co., Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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