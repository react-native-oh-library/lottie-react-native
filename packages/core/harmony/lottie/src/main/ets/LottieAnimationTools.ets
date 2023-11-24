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
 * WITHOUT WARRANTIES OR C ONDITIONS OF ANY KIND, either express or implied.
 * See the License for thespecific language governing permissions and
 * limitations under the License.
 */

import { AnimationObject, AnimationAssets } from './common/AnimationType'
import { isEmpty } from './common/TextUtils'

export function convertImageFolder(jsonData: AnimationObject, imagesFolder: string): AnimationObject {
  let assets: AnimationAssets[] = jsonData.assets
  if (assets != undefined && assets.length > 0 && !isEmpty(imagesFolder)) {
    if (imagesFolder.charAt(imagesFolder.length - 1) != '/') {
      imagesFolder = imagesFolder + '/'
    }
    let assetsTemp: AnimationAssets[] = assets.map((obj: AnimationAssets) => {
      obj.u = imagesFolder
      return obj
    })
    jsonData.assets = assetsTemp
  }
  return jsonData
}