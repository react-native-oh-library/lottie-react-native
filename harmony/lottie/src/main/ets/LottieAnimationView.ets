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

import { Descriptor, RNOHContext, RNViewBase } from '@rnoh/react-native-openharmony';
import lottie from '@ohos/lottie';
import { AnimationItem } from '@ohos/lottie';
import http from '@ohos.net.http';
import { AnimationObject, colorFiltersItem, layersItem, LottieViewProps,LOTTLE_STRING } from './common/AnimationType';
import { LottieCompositionCache } from './LottieCompositionCache';
import { convertImageFolder } from './LottieAnimationTools';
import { getHashCode } from './common/TextUtils';
import Logger from './Logger';

export const LOTTIE_TYPE: string = 'LottieAnimationView';
export type LottieViewDescriptor = Descriptor<'LottieAnimationView', LottieViewProps>;

@Component
export struct LottieAnimationView {
  ctx!: RNOHContext;
  tag: number = 0;
  @State descriptor: LottieViewDescriptor = {} as LottieViewDescriptor;
  private unregisterDescriptorChangesListener?: () => void = undefined;
  @State @Watch(LOTTLE_STRING.onStateChanged) progress: number = 0;
  @State @Watch(LOTTLE_STRING.onStateChanged) speed: number = 1;
  @State @Watch(LOTTLE_STRING.onStateChanged) loop: boolean = true;
  @State @Watch(LOTTLE_STRING.onStateChanged) autoPlay: boolean = false;
  @State @Watch(LOTTLE_STRING.onStateChanged) cacheComposition: boolean = true;
  private jsonData: AnimationObject | null = {} as AnimationObject;
  private jsonDataHashCode: string = '';
  private cleanupCommandCallback?: () => void = undefined;
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  private animateItem: AnimationItem | null = null;
  private lottieCache = LottieCompositionCache.getInstance();
  private animateKey: string | null = null;

  aboutToAppear() {
    this.descriptor = this.ctx.descriptorRegistry.getDescriptor<LottieViewDescriptor>(this.tag);
    this.commandCallback();
    this.subscribeToDescriptorChanges();
  }

  aboutToDisappear() {
    this.cleanupCommandCallback?.();
    this.unregisterDescriptorChangesListener?.();
    this.destroyAnimation();
    if (this.animateKey) {
      lottie.destroy(this.animateKey);
    }
    this.animateKey = null;
  }

  subscribeToDescriptorChanges(): void {
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor: object) => {
        this.descriptor = (newDescriptor as LottieViewDescriptor);
        this.onDescriptorChanged(true);
      }
    )
  }

  onDescriptorChanged(change?: boolean): void {
    if (this.descriptor.props) {
      this.handleColorFilters();
      this.updateWatchData();
      change && this.parseSourceURL();
    }
  }

  onStateChanged(propName: string): void {
    if (this.animateItem == null) {
      return;
    }
    switch (propName) {
      case LOTTLE_STRING.progress:
        this.setProgress();
        break;
      case  LOTTLE_STRING.speed:
        this.setSpeed();
        break;
      case  LOTTLE_STRING.loop: {
        this.animateItem.loop = this.loop;
        break;
      }
      case  LOTTLE_STRING.autoPlay:
        this.setAutoPlay();
        break;
      default:
        break;
    }
  }

  onAnimationFinish(isCancelled: boolean): void {
    this.ctx.rnInstance.emitComponentEvent(
      this.descriptor.tag,
      LOTTIE_TYPE,
      {
        type: LOTTLE_STRING.onAnimationFinish,
        isCancelled: isCancelled,
      }
    );
  }

  onAnimationCancel(): void {
    this.onAnimationFinish(true);
  }

  onAnimationEnd(): void {
    this.onAnimationFinish(false);
  }

  cacheProcessing(data: string, isURL?: boolean): void {
    const hashCode = getHashCode(data);
    if (hashCode === this.jsonDataHashCode) {
      return;
    }
    if (this.descriptor.props.cacheComposition) {
      const tempJsonObj = this.getCacheData(hashCode);
      if (tempJsonObj) {
        this.jsonData = tempJsonObj;
        this.jsonDataHashCode = hashCode;
        this.initAnimation();
        return;
      }
    }
    if (isURL) {
      this.request(data, hashCode);
    } else {
      this.updateJsonData(data, hashCode);
    }
  }

  parseSourceURL(): void {
    if (!this.descriptor?.props) {
      return;
    }
    if (this.descriptor.props.sourceURL.startsWith( LOTTLE_STRING.http)) {
      this.cacheProcessing(this.descriptor.props.sourceURL, true);
    } else {
      this.cacheProcessing(this.descriptor.props.sourceJson);
    }
  }

  request(url: string, hashCode?: string): void {
    Logger.debug('httpRequest.request url:', url);
    const httpRequest = http.createHttp();
    httpRequest.request(url, { header: {  [LOTTLE_STRING.contentType]:  LOTTLE_STRING.json} }, (err, data) => {
      if (err == undefined && data != undefined) {
        Logger.debug('httpRequest.request success:' + JSON.stringify(data));
        const result: Object = data.result;
        if (result) {
          this.updateJsonData(result as string, hashCode);
        }
      } else {
        Logger.error('httpRequest.request error:', `errorCode: ${err?.code}`);
      }
    })
  }

  updateWatchData(): void {
    this.progress = this.descriptor.props.progress;
    this.speed = this.descriptor.props.speed;
    this.loop = Boolean(this.descriptor.props.loop);
    this.autoPlay = Boolean(this.descriptor.props.autoPlay);
    this.cacheComposition = Boolean(this.descriptor.props.cacheComposition);
  }

  updateJsonData(data: string, hashCode?: string): void {
    try {
      this.jsonData = convertImageFolder(JSON.parse(data) as AnimationObject, this.descriptor.props.imageAssetsFolder);
      this.initAnimation();
      this.setCacheData(this.jsonData, hashCode);
    } catch (e) {
      Logger.error('updateJsonData,source parse error');
      this.jsonData = null;
    }
  }

  setCacheData(jsonObj: AnimationObject, key?: string): void {
    if (key) {
      this.lottieCache.set(key, jsonObj);
      this.jsonDataHashCode = key;
    }
  }

  getCacheData(key: string): AnimationObject | null {
    return this.lottieCache.get(key);
  }

  initAnimation(): void {
    if (this.jsonData == null) {
      return;
    }
    this.loadAnimation();
    this.setSpeed();
    this.addEventFrameListener();
  }

  destroyAnimation(): void {
    if (this.animateItem == null) {
      return;
    }
    if (this.animateItem.isPaused === false) {
      this.onAnimationEnd();
    }
    lottie.destroy(this.animateKey);
    this.animateItem = null;
  }

  loadAnimation(): void {
    this.destroyAnimation();
    this.animateKey = `${this.tag}${new Date().getTime()}`;
    this.animateItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer:  LOTTLE_STRING.canvas,
      name: this.animateKey,
      loop: Boolean(this.descriptor.props.loop),
      autoplay: Boolean(this.descriptor.props.autoPlay),
      animationData: this.jsonData
    });
    this.animateItem?.addEventListener( LOTTLE_STRING.DOMLoaded, () => {
      this.onDescriptorChanged();
    })
  }

  handleColorFilters(): void {
    const layersData: Array<layersItem> = this.jsonData?.layers ?? [];
    const colorFiltersData: Array<colorFiltersItem> = this.descriptor.rawProps[ LOTTLE_STRING.colorFilters] ?? [];
    for (const item of colorFiltersData) {
      const index: number = layersData.findIndex((layersItem: layersItem) => layersItem?.nm === item?.keypath);
      const color: Array<number> = this.getColorByColorFilters(item);
      const isIndex: boolean = index !== (-1);
      const isColor: boolean = color.length === 3;
      if (isIndex && isColor) {
        this.animateItem?.changeColor(color, index + 1);
        Logger.debug('colorFilters success:' + item?.keypath);
      } else {
        Logger.error('colorFilters fail:not find keyPath', item?.keypath);
      }
    }
  }

  getColorByColorFilters(colorFiltersItem: colorFiltersItem): Array<number> {
    const color: string = colorFiltersItem?.color;
    if (color) {
      const processColor: number = Number(color);
      const r: number = (processColor >> 16) & 0xff;
      const g: number = (processColor >> 8) & 0xff;
      const b: number = processColor & 0xff;
      Logger.debug(`getColorByColorFilters, r=${r}, g=${g}, b=${b}`);
      return [r, g, b];
    }
    Logger.error('colorFilters fail:not find color', colorFiltersItem?.keypath);
    return [];
  }

  setProgress(): void {
    const frame = this.getAnimateFrame();
    this.animateItem?.goToAndStop(frame, true);
  }

  setSpeed(): void {
    this.animateItem?.setSpeed(this.descriptor.props.speed);
  }

  setAutoPlay(): void {
    this.animateItem?.goToAndPlay(this.getAnimateFrame(), true);
  }

  getAnimateFrame(): number {
    const firstFrame: number = this.animateItem?.firstFrame ?? 0;
    const totalFrames: number = this.animateItem?.totalFrames ?? 0;
    return Math.ceil(firstFrame + this.descriptor.props.progress * totalFrames);
  }

  addEventFrameListener(): void {
    this.completeEvent();
  }

  completeEvent(): void {
    //动画播放结束且不再播放动画触发
    this.animateItem?.addEventListener( LOTTLE_STRING.complete, () => {
      this.onAnimationFinish(false);
    })
  }

  commandCallback(): void {
    this.cleanupCommandCallback = this.ctx.componentCommandReceiver.registerCommandCallback(
      this.tag,
      (command: string, args: object) => {
        if (this.animateItem == null) {
          return;
        }
        switch (command) {
          case  LOTTLE_STRING.play:
            this.play(args as number[]);
            break;
          case  LOTTLE_STRING.reset:
            this.reset();
            break;
          case  LOTTLE_STRING.pause:
            this.pause();
            break;
          case  LOTTLE_STRING.resume:
            this.resume();
            break;
          default:
            Logger.warn('not find command');
            break;
        }
      })
  }

  play(args: number[]): void {
    const startFrame = args[0];
    const endFrame = args[1];
    this.animateItem?.stop();
    if (this.progress !== 0) {
      this.progress = 0;
      this.animateItem?.goToAndPlay(this.getAnimateFrame(), true);
      return;
    }
    if (args.length > 1 && startFrame != -1 && endFrame != -1) {
      if (startFrame > endFrame) {
        this.animateItem?.setSegment(endFrame, startFrame);
        if (this.descriptor.props.speed > 0) {
          this.animateItem?.setDirection(-1);
        }
      } else {
        this.animateItem?.setSegment(startFrame, endFrame);
        if (this.descriptor.props.speed < 0) {
          this.animateItem?.setDirection(-1);
        }
      }
    }
    this.animateItem?.play();
  }

  reset(): void {
    this.animateItem?.stop();
    this.onAnimationEnd();
  }

  pause(): void {
    this.animateItem?.pause();
  }

  resume(): void {
    if (this.animateItem?.isPaused) {
      this.animateItem?.togglePause();
    }
  }

  resize(): void {
    this.animateItem?.resize();
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      Canvas(this.canvasRenderingContext)
        .width('100%')
        .height('100%')
        .onReady(() => this.parseSourceURL())
        .onAreaChange(() => this.resize())
    }
  }
}
