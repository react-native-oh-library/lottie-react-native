// Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
// Use of this source code is governed by a Apache-2.0 license that can be
// found in the LICENSE file.

import type {
  DirectEventHandler,
    Int32,
    Double,
    Float,
  } from 'react-native/Libraries/Types/CodegenTypes';
  import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
  import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
  import type {ProcessedColorValue,ViewProps, HostComponent } from 'react-native';
  import type { UnsafeMixed } from './codegenUtils';

  export type OnAnimationFinishEvent = Readonly<{
    isCancelled: boolean;
  }>;
  
  export type AnimationFailureEvent = Readonly<{
    error: string;
  }>;
  
  export type AnimationLoadedEvent = Readonly<{}>
  
  type ColorFilterStruct = Readonly<{
    keypath: string;
    color: ProcessedColorValue;
  }>;
  
  export interface NativeProps extends ViewProps {
    resizeMode?: string;
    renderMode?: string;
    sourceName?: string;
    sourceJson?: string;
    sourceURL?: string;
    imageAssetsFolder?: string;
    progress?: Float;
    speed?: Double;
    loop?: boolean;
    autoPlay?: boolean;
    enableMergePathsAndroidForKitKatAndAbove?: boolean;
    hardwareAccelerationAndroid?: boolean;
    cacheComposition?: boolean;
    colorFilters?:UnsafeMixed<ReadonlyArray<ColorFilterStruct>>;
    onAnimationFinish?: DirectEventHandler<
      OnAnimationFinishEvent,
      'onAnimationFinish'
    >;
    onAnimationFailure?: DirectEventHandler<
      AnimationFailureEvent,
      'onAnimationFailure'
    >;
    onAnimationLoaded?: DirectEventHandler<
      AnimationLoadedEvent,
      'onAnimationLoaded'
    >;
  }
  
  type LottieViewNativeComponentType = HostComponent<NativeProps>;
  
  interface NativeCommands {
    play: (
      viewRef: React.ElementRef<LottieViewNativeComponentType>,
      startFrame: Int32,
      endFrame: Int32,
    ) => void;
    reset: (viewRef: React.ElementRef<LottieViewNativeComponentType>) => void;
    pause: (viewRef: React.ElementRef<LottieViewNativeComponentType>) => void;
    resume: (viewRef: React.ElementRef<LottieViewNativeComponentType>) => void;
  }
  
  export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
    supportedCommands: ['play', 'reset', 'pause', 'resume'],
  });
  
  export default codegenNativeComponent<NativeProps>('LottieAnimationView') as HostComponent<NativeProps>;
  