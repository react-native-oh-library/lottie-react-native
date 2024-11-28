// Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
// Use of this source code is governed by a Apache-2.0 license that can be
// found in the LICENSE file.

import { AnimationObject, AnimationAssets } from './common/Animation'
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