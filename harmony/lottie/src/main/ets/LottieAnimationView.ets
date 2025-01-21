// Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
// Use of this source code is governed by a Apache-2.0 license that can be
// found in the LICENSE file.

import { RNOHContext, RNViewBase } from '@rnoh/react-native-openharmony';
import lottie from '@ohos/lottie';
import { AnimationItem } from '@ohos/lottie';
import http from '@ohos.net.http';
import { colorFiltersItem, LOTTLE_STRING } from './common/AnimationType';
import { AnimationObject, layersItem } from './common/Animation';
import { LottieCompositionCache } from './LottieCompositionCache';
import { convertImageFolder } from './LottieAnimationTools';
import { getHashCode } from './common/TextUtils';
import { RNOHLogger } from "@rnoh/react-native-openharmony/ts";
import { RNC } from './generated';
/**
 * @deprecated Use LottieAnimationView.NAME instead
 */
export const LOTTIE_TYPE: string = RNC.LottieAnimationView.NAME

@Component
export struct LottieAnimationView {
  public static readonly NAME = RNC.LottieAnimationView.NAME
  ctx!: RNOHContext;
  tag: number = 0;
  private logger!: RNOHLogger
  @State descriptorWrapper: RNC.LottieAnimationView.DescriptorWrapper = {} as RNC.LottieAnimationView.DescriptorWrapper;
  private unregisterDescriptorChangesListener?: () => void = undefined;
  @State @Watch('onStateChanged') progress: number = 0;
  @State @Watch('onStateChanged') speed: number = 1;
  @State @Watch('onStateChanged') loop: boolean = true;
  @State @Watch('onStateChanged') autoPlay: boolean = false;
  @State @Watch('onStateChanged') cacheComposition: boolean = true;
  private jsonData: AnimationObject | null = {} as AnimationObject;
  private jsonDataHashCode: string = '';
  private cleanupCommandCallback?: () => void = undefined;
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  private animateItem: AnimationItem | null = null;
  private lottieCache = LottieCompositionCache.getInstance();
  private animateKey: string | null = null;
  private eventEmitter: RNC.LottieAnimationView.EventEmitter | undefined = undefined

  aboutToAppear() {
    // 创建EventEmitter实例，用于处理事件的订阅和触发
    this.eventEmitter = new RNC.LottieAnimationView.EventEmitter(this.ctx.rnInstance, this.tag)
    this.logger = this.ctx!.logger.clone(RNC.LottieAnimationView.NAME)
    this.onDescriptorWrapperChange(this.ctx.descriptorRegistry.findDescriptorWrapperByTag<RNC.LottieAnimationView.DescriptorWrapper>(this.tag)!)
    this.commandCallback();
    this.subscribeToDescriptorChanges();
    this.logger.info(`testlottie:${JSON.stringify(this.descriptorWrapper.props)}`)
  }

  private onDescriptorWrapperChange(descriptorWrapper: RNC.LottieAnimationView.DescriptorWrapper) {
    this.descriptorWrapper = descriptorWrapper
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
        this.descriptorWrapper = (newDescriptor as RNC.LottieAnimationView.DescriptorWrapper);
        this.onDescriptorChanged(true);
      }
    )
  }

  onDescriptorChanged(change?: boolean): void {
    if (this.descriptorWrapper.props) {
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
      case LOTTLE_STRING.speed:
        this.setSpeed();
        break;
      case LOTTLE_STRING.loop: {
        this.animateItem.loop = this.loop;
        break;
      }
      case LOTTLE_STRING.autoPlay:
        this.setAutoPlay();
        break;
      default:
        break;
    }
  }

  onAnimationFinish(isCancelled: boolean): void {
    this.eventEmitter!.emit("animationFinish", {isCancelled: isCancelled});
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
    if (this.descriptorWrapper.props.cacheComposition) {
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
    if (!this.descriptorWrapper?.props) {
      return;
    }
    if (this.descriptorWrapper.props.sourceURL &&
    this.descriptorWrapper.props.sourceURL.startsWith(LOTTLE_STRING.http)) {
      this.cacheProcessing(this.descriptorWrapper.props.sourceURL, true);
    } else {
      this.descriptorWrapper.props.sourceJson && this.cacheProcessing(this.descriptorWrapper.props.sourceJson);
    }
  }

  request(url: string, hashCode?: string): void {
    this.logger.debug('httpRequest.request url:', url);
    const httpRequest = http.createHttp();
    httpRequest.request(url, { header: { [LOTTLE_STRING.contentType]: LOTTLE_STRING.json } }, (err, data) => {
      if (err == undefined && data != undefined) {
        this.logger.debug('httpRequest.request success:' + JSON.stringify(data));
        const result: Object = data.result;
        if (result) {
          this.updateJsonData(result as string, hashCode);
        }
      } else {
        this.logger.error('httpRequest.request error:', `errorCode: ${err?.code}`);
      }
    })
  }

  updateWatchData(): void {
    this.progress = this.descriptorWrapper.props.progress;
    this.speed = this.descriptorWrapper.props.speed;
    this.loop = Boolean(this.descriptorWrapper.props.loop);
    this.autoPlay = Boolean(this.descriptorWrapper.props.autoPlay);
    this.cacheComposition = Boolean(this.descriptorWrapper.props.cacheComposition);
  }

  updateJsonData(data: string, hashCode?: string): void {
    try {
      this.jsonData =
        convertImageFolder(JSON.parse(data) as AnimationObject,
          this.descriptorWrapper.props.imageAssetsFolder as string);
      this.initAnimation();
      this.setCacheData(this.jsonData as AnimationObject, hashCode);
    } catch (e) {
      this.logger.error('updateJsonData,source parse error');
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
      renderer: LOTTLE_STRING.canvas,
      name: this.animateKey,
      autoSkip:false,
      loop: Boolean(this.descriptorWrapper.props.loop),
      autoplay: Boolean(this.descriptorWrapper.props.autoPlay),
      animationData: this.jsonData
    });
    this.animateItem?.addEventListener(LOTTLE_STRING.DOMLoaded, () => {
      let upperResizeMode =
        this.descriptorWrapper.props.resizeMode?.replace(this.descriptorWrapper.props.resizeMode[0],
          this.descriptorWrapper.props.resizeMode[0].toUpperCase())
      this.eventEmitter!.emit("animationLoaded", {});
      this.animateItem?.setContentMode(upperResizeMode);
      this.onDescriptorChanged();
    })
    this.animateItem?.addEventListener(LOTTLE_STRING.data_failed, () => {
      this.eventEmitter!.emit("animationFailure", {error: 'data_failed'});
    })
  }

  handleColorFilters(): void {
    const layersData: Array<layersItem> = this.jsonData?.layers ?? [];
    const colorFiltersData: Array<colorFiltersItem> =
      this.descriptorWrapper.props.colorFilters as Array<colorFiltersItem>;
    for (const item of colorFiltersData) {
      const index: number = layersData.findIndex((layersItem: layersItem) => layersItem?.nm === item?.keypath);
      const color: Array<number> = this.getColorByColorFilters(item);
      const isIndex: boolean = index !== (-1);
      const isColor: boolean = color.length === 3;
      if (isIndex && isColor) {
        this.animateItem?.changeColor(color, index + 1);
        this.logger.debug('colorFilters success:' + item?.keypath);
      } else {
        this.logger.error('colorFilters fail:not find keyPath', item?.keypath);
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
      this.logger.debug(`getColorByColorFilters, r=${r}, g=${g}, b=${b}`);
      return [r, g, b];
    }
    this.logger.error('colorFilters fail:not find color', colorFiltersItem?.keypath);
    return [];
  }

  setProgress(): void {
    const frame = this.getAnimateFrame();
    this.animateItem?.goToAndStop(frame, true);
  }

  setSpeed(): void {
    this.animateItem?.setSpeed(this.descriptorWrapper.props.speed);
  }

  setAutoPlay(): void {
    this.animateItem?.goToAndPlay(this.getAnimateFrame(), true);
  }

  getAnimateFrame(): number {
    const firstFrame: number = this.animateItem?.firstFrame ?? 0;
    const totalFrames: number = this.animateItem?.totalFrames ?? 0;
    return Math.ceil(firstFrame + this.descriptorWrapper.props.progress * totalFrames);
  }

  addEventFrameListener(): void {
    this.completeEvent();
  }

  completeEvent(): void {
    //动画播放结束且不再播放动画触发
    this.animateItem?.addEventListener(LOTTLE_STRING.complete, () => {
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
          case LOTTLE_STRING.play:
            this.play(args as number[]);
            break;
          case LOTTLE_STRING.reset:
            this.reset();
            break;
          case LOTTLE_STRING.pause:
            this.pause();
            break;
          case LOTTLE_STRING.resume:
            this.resume();
            break;
          default:
            this.logger.warn('not find command');
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
        if (this.descriptorWrapper.props.speed > 0) {
          this.animateItem?.setDirection(-1);
        }
      } else {
        this.animateItem?.setSegment(startFrame, endFrame);
        if (this.descriptorWrapper.props.speed < 0) {
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
