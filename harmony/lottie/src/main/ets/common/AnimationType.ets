// Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
// Use of this source code is governed by a Apache-2.0 license that can be
// found in the LICENSE file.

import { ViewRawProps } from '@rnoh/react-native-openharmony'

export interface LottieViewState {}

export interface colorFiltersItem {
  keypath: string;
  color: string
}

export interface LottieViewProps extends ViewRawProps {
  resizeMode: string
  renderMode: string
  sourceName: string
  sourceJson: string
  sourceURL: string
  imageAssetsFolder: string
  progress: number
  speed: number
  loop: boolean
  autoPlay: boolean
  enableMergePathsAndroidForKitKatAndAbove: boolean
  hardwareAccelerationAndroid: boolean
  cacheComposition: boolean
  colorFilters: Array<colorFiltersItem>
}

export enum LOTTLE_STRING {
  onStateChanged = 'onStateChanged',
  progress = 'progress',
  speed = 'speed',
  loop = 'loop',
  autoPlay = 'autoPlay',
  onAnimationFinish = 'onAnimationFinish',
  http = 'http',
  contentType = 'Content-Type',
  json = 'application/json',
  canvas = 'canvas',
  DOMLoaded = 'DOMLoaded',
  colorFilters = 'colorFilters',
  complete = 'complete',
  play = 'play',
  reset = 'reset',
  pause = 'pause',
  resume = 'resume',
  data_failed = 'data_failed'
}