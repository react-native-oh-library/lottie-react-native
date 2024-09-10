export interface layersItem {
  "ddd"?: number;
  "ind"?: number;
  "ty"?: number;
  "nm"?: string;
  "sr"?: number;
  "ks": object;
  "ao"?: number;
  "shapes": Array<{ [key: string]: string | number }>
  "ip"?: number;
  "op"?: number;
  "st"?: number;
  "bm"?: number;

  [key: string]: string | number | object | [];
}

export type AnimationObject = {
  v: string
  fr: number
  ip: number
  op: number
  w: number
  h: number
  nm?: string
  ddd?: number
  assets: AnimationAssets[]
  layers: layersItem[]
  markers?: Object[]
}

export type AnimationAssets = {
  id: string
  w: number
  h: number
  u: string
  p: string
  e: number
}