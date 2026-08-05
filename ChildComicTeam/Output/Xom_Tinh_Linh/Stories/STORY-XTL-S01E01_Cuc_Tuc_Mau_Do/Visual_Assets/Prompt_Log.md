# Visual Prototype Prompt Log

## Provenance

- Project: `STORY-XTL-S01E01 — Cục Tức Màu Đỏ`
- Created: `04/08/2026`
- Method: OpenAI image generation through Codex `imagegen` workflow.
- Purpose: internal style/storyboard review only; not final publication art.
- External artist/franchise reference: none.
- Human review required before final art, release and rights approval.

## `VD-01_Character_Styleboard_v1.png`

Final direction: original Vietnamese children’s comic styleboard on warm paper, gouache/colored-pencil texture; full and expression views for Bắp, Lam and Cô Sen; silhouette checks; four abstract red folded states for Cục Tức; no readable text, logo, watermark, artist imitation, horror or face on the sprite.

Output copied to: `Visual_Assets/VD-01_Character_Styleboard_v1.png`.

## `SAMPLE-P04_Visual_Trigger_v1.png`

Prompt: portrait 4:5 full comic page, exactly three panels. Bắp in the neighborhood courtyard forces a smile beside the crooked handmade festival sign and tangled red ribbon; close-up of his hand gripping the satchel strap and tightened shoulders; final quiet close-up from behind as he notices a small ambiguous red fold near the ground. Match `VD-01`; warm gouache/colored pencil; no readable text or balloons. The sprite reflects emotion but does not control him and must not look evil, flaming, monstrous or face-like.

Output copied to: `Visual_Assets/SAMPLE-P04_Visual_Trigger_v1.png`.

## `SAMPLE-P12_Emotional_Climax_v1.png`

Prompt: portrait 4:5 full comic page, exactly two panels. Large climax panel in the courtyard: torn red ribbon and crooked sign, Bắp stops pretending and chooses to speak honestly, Lam listens at a respectful distance, CT-3 is a very large abstract red folded mass with no face/limbs/flames and no attack. Quiet second panel: tear on Bắp’s cheek and loosened satchel grip. Match `VD-01`; no magic solution, readable text, balloons, title, logo or watermark.

Output copied to: `Visual_Assets/SAMPLE-P12_Emotional_Climax_v1.png`.

## `SAMPLE-P24_Resolution_v1.png`

Prompt: portrait 4:5 full comic page, exactly two panels. Small top panel: Bắp gently re-ties the red ribbon around a repaired blank sign while Lam’s notebook/pencil and tiny calm CT-4 appear. Large ending splash at sunset: Bắp, Lam and Cô Sen with neighbors completing handmade festival decorations; repaired blank sign, open lettering area, CT-4 still beside Bắp’s foot. Match `VD-01`; human listening and teamwork solve the problem, not magic. No readable text, balloons, title, logo or watermark.

Output copied to: `Visual_Assets/SAMPLE-P24_Resolution_v1.png`.

## Known prototype limitations

- These images test style, emotion, silhouette and page rhythm; they do not replace the authoritative 73-panel script.
- Final art must reconstruct exact prop positions, screen direction, panel-specific action and Vietnamese lettering from `03_Comic_Script.md`.
- Grayscale, font licensing, print profile and full 24-page continuity remain production checks.

## `VD-02_Production_Model_Sheet_v1.png`

Prompt: use approved `VD-01` as the exact identity/style reference; create a portrait 4:5 production sheet with full-body front, three-quarter, side and back views plus expression heads for Bắp, Lam and Cô Sen. Add exactly four separate Cục Tức states with a grayscale silhouette duplicate under each. Preserve all locked costumes, props, proportions and gouache/colored-pencil texture; no readable labels, franchise/artist imitation, face/limbs/flames on the sprite, logo or watermark.

Output copied to: `Visual_Assets/VD-02_Production_Model_Sheet_v1.png`.

## Batch A rough prompt set — `P01–P06`

- Shared instruction: use `VD-02` as exact model and the preceding approved page as location/style continuity; portrait 4:5; warm late-afternoon Vietnamese courtyard; gouache/colored-pencil texture; no readable text, balloons, logo or watermark.
- `P01`: exactly 3 panels; establish courtyard geography, narrow right walkway, Cô Sen anchor, busy Bắp and observing Lam.
- `P02`: exactly 3 panels; Bắp presents intact three-layer red paper sun, Lam notices blocked path, friend asks Bắp for help.
- `P03`: exactly 4 quick panels; Bắp ties, passes glue, Lam tests walkway, then rotates board/moves props without asking.
- `P04`: exactly 3 increasingly close panels; Bắp sees changed layout, Lam explains open path, Bắp grips a red ray and forces a smile; no Cục Tức.
- `P05`: two small panels over one large; first CT-1 appearance under table, tense fold echoes Bắp, friend borrows moved ribbon box; sprite never controls objects.
- `P06`: three horizontal panels; Lam checks in, Bắp gathers too many tools, CT-1 grows marble → lemon behind the table.

Outputs copied to `Visual_Assets/ROUGH-P01_BatchA_v1.png` through `ROUGH-P06_BatchA_v1.png`. See `09B_Batch_A_Production_and_QA.md` for continuity findings; these are roughs, not final art.

## Batch A correction prompt set — `v2`

- Method: built-in image edit, use case `precise-object-edit`; each v1 page was the edit target.
- Single targeted change across P01–P06: remove every duplicate red folded sun/rosette mounted at the board’s top center; restore plain bamboo rail/cream board; preserve the sole real sun in Bắp’s hands or on the table.
- Locked invariants: panel count/layout, identities, poses, props other than duplicate sun, courtyard, lighting, texture, balloon space and CT-1 states.
- P06 source required a lossless PNG re-encode for tool compatibility; visual content was unchanged before the edit.

Outputs copied to `Visual_Assets/ROUGH-P01_BatchA_v2.png` through `ROUGH-P06_BatchA_v2.png`; lettering siblings are `LETTERED-P01_BatchA_v2.svg` through `LETTERED-P06_BatchA_v2.svg`.

## Batch B rough prompt set — `P07–P12`

- Shared: built-in `imagegen`, illustration-story; `VD-02` and P06/P09 continuity references; portrait 4:5; exact panel counts; no in-image text.
- P07: four quick panels, overwork, ruler drop, Lam offers help, Bắp takes ruler too quickly.
- P08: CT-2 ball-size shape humour through stool gap; no fall or injury.
- P09: increasing CT occlusion; rope knot behind rotated board established clearly.
- P10: three tense rope panels; safe grip; Lam points at knot; one sun mounted once.
- P11: real pause/choice, Lam holds board edge, Bắp pulls, CT-3 mirrors tension; no tear yet.
- P12: two panels, hand–rope–knot–tear causality, CT-3 touches nothing, safe silence after damage.

Corrections: P11 v2 restored Lam/sun continuity; P11 v3 removed duplicate Bắp. P12 v2 removed a duplicate tabletop sun. Final workspace outputs are `ROUGH-P07_BatchB_v1.png`…`ROUGH-P10_BatchB_v1.png`, `ROUGH-P11_BatchB_v3.png`, and `ROUGH-P12_BatchB_v2.png` with matching lettering SVGs.

## Batch C rough prompt set — `P13–P18`

- Shared: built-in `imagegen`; exact `VD-02` identities, P12/P15 continuity, portrait 1024×1536, fixed panel counts, warm hand-painted courtyard, no in-image text/balloons/logo/watermark.
- P13: three panels; Bắp sees that Cục Tức has swollen, Lam states the observed hand action without blame, Bắp leaves for the doorstep while Cục remains linked to him.
- P14: three panels, tight-to-open; Bắp sits heavily, Cô Sen offers a real distance choice, then sits at the far point Bắp selects. No punishment, forced calming or touch.
- P15: three quiet panels; feet/hands/body cue, Bắp names pain from squeezing, Cô Sen places water within reach and withdraws; Cục stops swelling but does not disappear.
- P16: three panels; Cục divides Bắp and Lam, only Lam’s pencil hand appears over the coil, Bắp turns his chair and chooses to speak. Torn board rests safely on a table.
- P17: two large panels; Bắp names anger, then points to the torn sun/board rather than Lam; Cục lowers slightly but remains substantial.
- P18: three balanced panels; Lam explains the walking path and acknowledges she should have asked; Bắp admits “không sao” was not true; Cục transitions toward a visible medium state.

Initial outputs: `ROUGH-P13_BatchC_v1.png`, `ROUGH-P14_BatchC_v1.png`, `ROUGH-P15_BatchC_v1.png`, `ROUGH-P16_BatchC_v1.png`, `ROUGH-P17_BatchC_v1.png`, `ROUGH-P18_BatchC_v1.png`.

## Batch C correction prompt set — `P14/P15 v2`

- Method: precise-object edit against each v1 target plus `VD-02`.
- P14: replace Lam in panels 2–3 with Cô Sen—adult proportions, low bun, cream tunic, mauve scarf, plum trousers—while preserving Bắp, Cục, respectful distance, panel layout and background.
- P15: replace Lam in panel 3 with Cô Sen placing water within reach and withdrawing her hand; preserve panels 1–2, Bắp, board and large non-disappearing Cục.

Final workspace roughs: `ROUGH-P13_BatchC_v1.png`, `ROUGH-P14_BatchC_v2.png`, `ROUGH-P15_BatchC_v2.png`, `ROUGH-P16_BatchC_v1.png`, `ROUGH-P17_BatchC_v1.png`, `ROUGH-P18_BatchC_v1.png`. Matching lettering: `LETTERED-P13_BatchC_v1.svg`, `LETTERED-P14_BatchC_v2.svg`, `LETTERED-P15_BatchC_v2.svg`, `LETTERED-P16_BatchC_v1.svg`, `LETTERED-P17_BatchC_v1.svg`, `LETTERED-P18_BatchC_v1.svg`.

## Batch D rough prompt set — `P19–P24`

- Shared: built-in `imagegen`, illustration-story; `VD-02` plus P18/P21 and ending sample continuity; portrait 1024×1536; exact panel counts; one physical board/sun; visible tear/seam; open walkway; no in-image text.
- P19: three panels; Bắp and Lam return without being surrounded, Bắp places his hand beside the tear and accepts responsibility, Lam sets down repair paper; Cô Sen works elsewhere.
- P20: four panels; Lam tests moving the sun, Bắp stops before grabbing, both combine the red center with multicolored rays while preserving the path.
- P21: four-panel repair montage; child-safe paste, a background child offers rays, Bắp accepts one task and pauses before touching Lam’s placement, both move it together.
- P22: three panels; visible branching seam connects the red center and colored rays, Lam does not hide the seam, CT-4 remains as a tangerine-sized folded creature.
- P23: three panels; children lift the board, it hangs slightly crooked, Bắp asks Lam before changing it; CT-4 stays at his foot.
- P24: exactly two panels; shared adjustment above and wide courtyard ending below; blank title band inside the board; Bắp in the group, open path, CT-4 visible, Cô Sen working in the background.

Initial outputs were copied as `ROUGH-P19_BatchD_v1.png` through `ROUGH-P24_BatchD_v1.png` for provenance.

## Batch D correction prompt set

- `P21-v2`: replace Cô Sen in the material handoff with a distinct child friend; preserve all other panels.
- `P21-v3`: move Bắp’s hand back in panel 3 to create a clear gap before asking permission.
- `P22-v2`: remove duplicate loose red sun crafts while preserving the integrated center sun.
- `P22-v3`: restore exactly one tiny braided CT-4 in panel 3 without reintroducing a sun duplicate.
- `P23-v2`: replace the adult lifter with a child friend in panel 1 and remove the adult from between Bắp and Lam in panels 2–3.
- `P24-v2`: regenerate as exactly two panels; place the blank title band inside the board and retain CT-4/open walkway.

Final workspace roughs: `ROUGH-P19_BatchD_v1.png`, `ROUGH-P20_BatchD_v1.png`, `ROUGH-P21_BatchD_v3.png`, `ROUGH-P22_BatchD_v3.png`, `ROUGH-P23_BatchD_v2.png`, `ROUGH-P24_BatchD_v2.png`. Matching final-manifest lettering: `LETTERED-P19_BatchD_v1.svg`, `LETTERED-P20_BatchD_v1.svg`, `LETTERED-P21_BatchD_v3.svg`, `LETTERED-P22_BatchD_v3.svg`, `LETTERED-P23_BatchD_v2.svg`, `LETTERED-P24_BatchD_v2.svg`.

## Full-book canvas normalization

Device preflight found P01/P03 v2 at `1007×1562` while the lettering canvas is `1024×1536`. Both raster pages were deterministically resampled to versioned `ROUGH-P01_BatchA_v3.png` and `ROUGH-P03_BatchA_v3.png` at `1024×1536`; content, panels and lettering positions were not redesigned. Final-manifest SVG siblings are `LETTERED-P01_BatchA_v3.svg` and `LETTERED-P03_BatchA_v3.svg`.
