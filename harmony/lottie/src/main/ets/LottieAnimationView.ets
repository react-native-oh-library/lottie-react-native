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

import {
  Descriptor,
  ComponentBuilderContext,
  RNOHContext,
  ViewDescriptorWrapper,
  ViewBaseDescriptor,
  RNViewManager
} from 'rnoh'
import lottie from '@ohos/lottie'
import { AnimationItem } from '@ohos/lottie'
import http from '@ohos.net.http'
import { AnimationObject, LottieViewProps } from './common/AnimationType'
import { LottieCompositionCache } from './LottieCompositionCache'
import { convertImageFolder } from './LottieAnimationTools'
import { getHashCode } from './common/TextUtils'
//import { ViewModifier } from 'rnoh/src/main/ets/RNOHCorePackage/componentAttributeModifiers/ViewModifier'
import { ViewModifier } from './ViewModifier'

export const LOTTIE_TYPE: string = "LottieAnimationView"

export type LottieViewDescriptor = Descriptor<"LottieAnimationView", LottieViewProps>

@Component
export struct LottieAnimationView {
  ctx!: RNOHContext
  tag: number = 0
  @BuilderParam buildCustomComponent: (componentBuilderContext: ComponentBuilderContext) => void
  @State descriptor: LottieViewDescriptor = {} as LottieViewDescriptor

  @State descriptorWrapper:ViewDescriptorWrapper | undefined = undefined
  public componentManager!: RNViewManager
  @State @Watch("onStateChanged") progress: number = 0
  @State @Watch("onStateChanged") speed: number = 1
  @State @Watch("onStateChanged") loop: boolean = true
  @State @Watch("onStateChanged") autoPlay: boolean = false
  @State @Watch("onStateChanged") cacheComposition: boolean = true
  private jsonData: AnimationObject | null = {} as AnimationObject
  private jsonDataHashCode: string = ''
  // private cleanupCommandCallback?: () => void = undefined
  private unregisterDescriptorChangesListener?: () => void = undefined
  private unregisterComponentManager?: () => void = undefined
  private unregisterCommandCallback?: () => void = undefined
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings)
  private animateItem: AnimationItem | null = null
  private lottieCache = LottieCompositionCache.getInstance()

  aboutToAppear() {
    this.initComponent()
    this.descriptor = this.ctx.descriptorRegistry.getDescriptor<LottieViewDescriptor>(this.tag)
    this.onDescriptorChanged()
    this.commandCallback()
    this.subscribeToDescriptorChanges()
  }

  aboutToDisappear() {
    this.unregisterDescriptorChangesListener?.()
    this.unregisterComponentManager?.()
    this.unregisterCommandCallback?.()
    this.destroyAnimation()
  }

  initComponent() {
    let descriptor = this.ctx.descriptorRegistry.getDescriptor<ViewBaseDescriptor>(this.tag)
    if(!this.componentManager){
      this.componentManager = new RNViewManager(this.tag,this.ctx)
    }
    this.unregisterComponentManager = this.ctx.componentManagerRegistry.registerComponentManager(this.tag,this.componentManager)
    this.setDescriptorWrapper(descriptor)
    const parentTag = descriptor.parentTag
    this.componentManager.setParentTag(parentTag)
  }

  subscribeToDescriptorChanges(): void {
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor: object) => {
        this.descriptor = (newDescriptor as LottieViewDescriptor)
        this.setDescriptorWrapper(newDescriptor as ViewBaseDescriptor)
        this.onDescriptorChanged(true)
      }
    )
  }

  setDescriptorWrapper(descriptor: ViewBaseDescriptor){
    this.descriptorWrapper = new ViewDescriptorWrapper(descriptor)
  }
  onDescriptorChanged(change?: boolean): void {
    if (this.descriptor.props) {
      this.updateWatchData()
      if (change) {
        this.parseSourceURL()
      }
    }
  }

  onStateChanged(propName: string): void {
    if (this.animateItem == null) {
      return
    }
    switch (propName) {
      case 'progress':
        this.setProgress()
        break;
      case 'speed':
        this.setSpeed()
        break;
      case 'loop':
        this.animateItem.loop = this.loop
        break;
      case 'autoPlay':
        this.setAutoPlay()
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
        type: "onAnimationFinish",
        isCancelled: isCancelled
      }
    )
  }

  onAnimationCancel(): void {
    this.onAnimationFinish(true)
  }

  onAnimationEnd(): void {
    this.onAnimationFinish(false)
  }

  cacheProcessing(data: string, isURL?: boolean): void {
    const hashCode = getHashCode(data)
    if (hashCode === this.jsonDataHashCode) {
      return
    }
    if (this.descriptor.props.cacheComposition) {
      const tempJsonObj = this.getCacheData(hashCode)
      if (tempJsonObj) {
        this.jsonData = tempJsonObj
        this.jsonDataHashCode = hashCode
        this.initAnimation()
        return
      }
    }
    if (isURL) {
      this.request(data, hashCode)
    } else {
      this.updateJsonData(data, hashCode)
    }
  }

  parseSourceURL(): void {
    if (this.descriptor.props.sourceURL.startsWith('http')) {
      this.cacheProcessing(this.descriptor.props.sourceURL, true)
    } else {
      this.cacheProcessing(this.descriptor.props.sourceJson)
    }
  }

  request(url: string, hashCode?: string): void {
    console.info('httpRequest.request url:' + JSON.stringify(url))
    const httpRequest = http.createHttp()
    httpRequest.request(url, { header: { 'Content-Type': 'application/json' } }, (err, data) => {
      if (err == undefined && data != undefined) {
        console.info('httpRequest.request success:' + JSON.stringify(data))
        const result: Object = data.result
        if (result) {
          this.updateJsonData(result as string, hashCode)
        }
      } else {
        console.info('httpRequest.request error:' + JSON.stringify(err))
      }
    })
  }

  updateWatchData(): void {
    this.progress = this.descriptor.props.progress
    this.speed = this.descriptor.props.speed
    this.loop = Boolean(this.descriptor.props.loop)
    this.autoPlay = Boolean(this.descriptor.props.autoPlay)
    this.cacheComposition = Boolean(this.descriptor.props.cacheComposition)
  }

  updateJsonData(data: string, hashCode?: string): void {
    try {
      this.jsonData = convertImageFolder(JSON.parse(data) as AnimationObject, this.descriptor.props.imageAssetsFolder)
      this.initAnimation()
      this.setCacheData(this.jsonData, hashCode)
    } catch (e) {
      this.jsonData = null
    }
  }

  setCacheData(jsonObj: AnimationObject, key?: string): void {
    if (key) {
      this.lottieCache.set(key, jsonObj)
      this.jsonDataHashCode = key
    }
  }

  getCacheData(key: string): AnimationObject | null {
    return this.lottieCache.get(key)
  }

  initAnimation(): void {
    if (this.jsonData == null) {
      return
    }
    this.loadAnimation()
    this.setSpeed()
    this.addEventFrameListener()
  }

  destroyAnimation(): void {
    if (this.animateItem == null) {
      return
    }
    if (this.animateItem.isPaused === false) {
      this.onAnimationEnd()
    }
    this.animateItem.destroy()
    this.animateItem = null
  }

  loadAnimation(): void {
    this.destroyAnimation()
    this.animateItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer: 'canvas',
      loop: Boolean(this.descriptor.props.loop),
      autoplay: Boolean(this.descriptor.props.autoPlay),
      animationData: this.jsonData
    })
  }

  setProgress(): void {
    const frame = this.getAnimateFrame()
    if (Boolean(this.descriptor.props.autoPlay)) {
      this.animateItem?.goToAndPlay(frame, true)
    } else {
      this.animateItem?.goToAndStop(frame, true)
    }
  }

  setSpeed(): void {
    this.animateItem?.setSpeed(this.descriptor.props.speed)
  }

  setAutoPlay(): void {
    this.animateItem?.goToAndPlay(this.autoPlay ? 0 : this.getAnimateFrame(), true)
  }

  getAnimateFrame(): number {
    let firstFrame: number = this.animateItem?.firstFrame ?? 0
    let totalFrames: number = this.animateItem?.totalFrames ?? 0
    return Math.ceil(firstFrame + this.descriptor.props.progress * totalFrames)
  }

  addEventFrameListener(): void {
    this.completeEvent()
  }

  completeEvent(): void {
    //动画播放结束且不再播放动画触发
    this.animateItem?.addEventListener('complete', () => {
      this.onAnimationFinish(false)
    })
  }

  commandCallback(): void {
    this.unregisterCommandCallback = this.ctx.componentCommandReceiver.registerCommandCallback(
      this.tag,
      (command: string, args: object) => {
        if (this.animateItem == null) {
          return
        }
        switch (command) {
          case 'play':
            this.play(args as number[])
            break
          case 'reset':
            this.reset()
            break
          case 'pause':
            this.pause()
            break
          case 'resume':
            this.resume()
            break
          default:
            break
        }
      })
  }

  play(args: number[]): void {
    const startFrame = args[0]
    const endFrame = args[1]
    if (args.length > 1 && startFrame != -1 && endFrame != -1) {
      if (startFrame > endFrame) {
        this.animateItem?.setSegment(endFrame, startFrame)
        if (this.descriptor.props.speed > 0) {
          this.animateItem?.setDirection(-1)
        }
      } else {
        this.animateItem?.setSegment(startFrame, endFrame)
        if (this.descriptor.props.speed < 0) {
          this.animateItem?.setDirection(-1)
        }
      }
    }
    this.animateItem?.stop()
    this.animateItem?.play()
  }

  reset(): void {
    this.animateItem?.stop()
    this.onAnimationEnd()
  }

  pause(): void {
    this.animateItem?.pause()
  }

  resume(): void {
    if (this.animateItem?.isPaused) {
      this.animateItem?.togglePause()
    }
  }

  resize(): void {
    this.animateItem?.resize()
  }

  build() {
    Stack(){
      Canvas(this.canvasRenderingContext)
        .width('100%')
        .height('100%')
        .onReady(() => this.parseSourceURL())
        .onAreaChange(() => this.resize())
    }
    .attributeModifier(ViewModifier.getInstance().setDescriptor(this.descriptorWrapper))
    .id(this.tag.toString())
  }
}
