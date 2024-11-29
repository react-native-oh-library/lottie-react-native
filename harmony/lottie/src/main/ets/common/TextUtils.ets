// Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
// Use of this source code is governed by a Apache-2.0 license that can be
// found in the LICENSE file.

export function isEmpty(str: string | null | undefined): boolean {
  return str == null || typeof str == 'undefined' || str.length == 0
}

export function getHashCode(str: string): string {
  let hash: number = 1315423911
  let i: number
  let ch: number
  for (i = str.length - 1; i >= 0; i--) {
    ch = str.charCodeAt(i)
    hash ^= ((hash << 5) + ch + (hash >> 2))
  }
  return (hash & 0x7FFFFFFF).toString()
}