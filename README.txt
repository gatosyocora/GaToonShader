GaToonShader
gatosyocoraが好き勝手に作ったアバター用シェーダーです
Toonシェーダーって名前ですが、たぶんぜんぜんToonシェーダーではないです
名前の「_Unlit」はシェーダーブロック対策でいれています
（シェーダーブロックされているとUnlitシェーダーに切り替わります。Toonって入ってるからToonになっちゃうかも）

〇内容物
- GatoFunc.cginc : いろんなところで使えそうな関数群です
- GaToon.cginc : 陰影の計算等をおこなう関数が書かれています
- GaToonShaderVoxel2_Unlit.shader : Voxelシェーダーです。ポリゴンにつき1つボクセルをつくります。（新型）
- GaToonShaderVoxel_Unlit.shader : Voxelシェーダーです。頂点につき1つのボクセルをつくります。（旧型）
- GaToonShader_Transpanrent.shader : Transparentシェーダーです。透明を扱えます。
- GaToonShader_TranspanrentCutOut.shader : TransparentCutoutシェーダーです。透明部分をカットします。
- GaToonShader_Unlit.shader : 最も基本的なシェーダーです。
- GaToonShaderEye_Unlit.shader : 目をいい感じにできるシェーダーです（現在はQuicheちゃん専用）

〇パラメータ説明
- Cull : CullingModeです。Off(カリングしない), Front(表面カリング), Back(裏面カリング)から選べます。デフォルトはBack
- Texture : ベースとなるテクスチャです。
- Albedo : 天体の外部からの入射光に対する反射率らしいですが、いわゆる全体的に色を変化させるものです。
- MinLightPower : 受ける光の最小値です。これよりは暗くなりません。

- CutoutLevel : カットする透明度を設定します。(GaToonShader_TranspanrentCutOutで設定可能)

- VirtualLight : バーチャルなリアルタイムライトに関する項目です。リアルタイムライトが存在しないワールドで参照します
 - Virtual Light Color : バーチャルなリアルタイムライトの色です。
 - Virtual Light Position : バーチャルなリアルタイムライトの位置です。

- Shadow : 影に関する項目です
 - Shadow Power : 影の濃さです。
 - Shadow Scale : 影の範囲です。
 - Shadow Blur : 影の境界のぼやけ具合です。
 - Shadow Color Mask : 影の色を箇所によって分けるためのマスク画像です。(設定なしは全体が白)
 - Shadow Color1 (black) : ShadowColorMaskで黒色のところにつける影の色です。
 - Shadow Color2 (white) : ShadowColorMaskで白色のところにつける影の色です。

- RimLight : リムライト(後ろから当たる光)に関する項目です
 - Use RimLight : リムライトを使うかどうかです。チェックを入れるとリムライトが有効になります。
 - RimLight Mask : リムライトが当たらない箇所を設定するためのマスク画像です。(黒いところに当たらない)
 - RimLightColor : リムライトの色です。
 - RimLightPower : リムライトの強さです。
 - RimLightScale : リムライトの範囲です。

- Outline : アウトラインに関する項目です
 - Use Outline : アウトラインを使うかどうかです。チェックを入れるとアウトラインが有効になります。
 - Outline Color : アウトラインの色です。
 - Outline Width : アウトラインの太さです。

- Matcap : マットキャップに関する項目です（ベータ）
 - Matcap : 使用するマットキャップ画像です。
 - Matcap Color : マットキャップと合成する色です。
 - MatcapMask : マットキャップが反映されない箇所を設定するためのマスク画像です。（黒いところに当たらない）
 - Calc Mode : マットキャップの合成方法を指定します。ADDは加算合成, MULは乗算合成です。
 - Inverse : チェックを入れるとMatcapに設定された画像を白黒反転させた画像として扱います。

- Voxel : ボクセルに関する項目です（GaToonShaderVoxel2_Unlit, GaToonShaderVoxel_Unlitで設定可）
 - VoxelScale : ボクセルの大きさを設定します。

- Tessellation : 頂点数に関する項目です（GaToonShaderVoxel2_Unlit, GaToonShaderVoxel_Unlitで設定可）
 - Tessellation Vector : どっち方向にメッシュを分割するかの項目です？頂点数を増やす場合はいずれかが1より大きい値である必要があります
 - Tessellation Mask : 頂点数を増やす箇所を設定するためのマスク画像です。(黒いところは増やさない)
 - Tessellation Raito : 増やした頂点数の割合を設定します。0だとまったく増やさず, 0.5だと50%増やして, 1だと設定値通りに増やします

 - Eye : 目に関する項目です（GaToonShaderEye_Unlitで設定可）
  - Is Quche Eye : チェックを入れるとULevelとVLevelをQucheちゃん用に値を設定します
  - Is Mirror : 未実装
  - U Level : テクスチャ上でU方向の目の範囲です
  - V Level : テクスチャ上でV方向の目の範囲です
  - Top Level : 未実装
  - Bottom Level : 未実装
  - Left Level : 未実装
  - Right Level : 未実装
  - Eye Texture : 目に貼るテクスチャです
  - BlackLevel : 上から黒く色を変化させる度合いです。
  - Speed : 目の色の変化速度です。

  〇利用規約
  著作権はgatosyocoraにあります
  アバターに使ってもOK。でも素人コードなので何が起こるか分からないです（問題が起きても保証できません）
  コードの解析や改変してもOK。こうしたほうがいいよみたいなアドバイスもお願いします...
  改変しないままの2次配布や販売は禁止です。あと自作発言もやめてね...

  何かあれば製作者のgatosyocora(@gatosyocora, @gatosyocora_vrc)まで連絡ください
