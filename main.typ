#import "@preview/polylux:0.3.1": *

#import "tfachmann-theme.typ": *

// rgb("#FF5D05"), 
#let c_primary = rgb("#E65100");
#let c_secondary = rgb("#0078b8");
#let c_background = rgb("#212121");
#let c_background_light = rgb("A2AABC")
#let c_white = rgb("#CFD8DC");

#set page(paper: "presentation-16-9")
#set line(stroke: 1pt + c_primary)

#set raw(theme: "halycon.tmTheme")
#show raw: it => block(
  fill: rgb("#2b303b"),
  inset: 1em,
  radius: 0.8em,
  text(fill: c_background_light, it)
)

#show heading: set text(c_primary)

#show: simple-theme.with(
  background: c_background,
  foreground: c_white,
  footer: [Optical Music Recognition - From Dataset Creation to Inference],
)

#title-slide[
  = #text(c_white, "Optical Music Recognition")
  From Dataset Creation to Inference

  #line(length: 100%)
  Timo Bachmann\

  #place(
    top + right,
    text(size: 20pt, [January 12th 2024])
  )
  

  #place(
    top + left, 
    text(
      c_secondary,
      size: 20pt,
      link("https://tfachmann.com/music-recognition/", [
        https:/\/#text(weight: "bold", [tfachmann])\.com
      ])
    )
  )
]

// #centered-slide[
//   = Act 1
//   == Writing a Music Renderer From Scratch
// ]

#centered-slide[
  = Act 1 -- 3
  == Music Rendering and Dataset Creation
]

#slide[
  = Act 1 - Writing a Music Renderer From Scratch

  #v(1em)

  #set text(size: 22pt)

  #side-by-side[
    #v(1em)
    - Very complex and opinionated rules
    - *Not* a complete positioning engine
    - Render *already engraved* music
      - MusicXML
      - PDF (images)
    #v(2em)
    #uncover(2)[#h(4em)... still needs some]
  ][
    #only(1)[
      #v(2em)
      #figure(
        image("./images/music_recognition.svg", width: 100%),
        supplement: "Fig",
      )
    ]
    #only(2)[
      #figure(
        image("./images/hierarchy_drawing.svg", width: 99%),
        supplement: "Fig",
      )
    ]

  ]
]
//
// #centered-slide[
//   = Act 2
//   == Filetype Agnostic Music Rendering
// ]

#slide[
  = Act 2 - Filetype Agnostic Music Rendering

  #set text(size: 22pt)

  #v(2.5em)
  - Challenge: Output SVGs, PNGs, Segmentation Masks, Bounding Boxes, ...

  - --> Rendering engine #text(c_primary, [independent]) of filetypes

  #place(bottom + left, [
    #figure(
      image("./images/img.png", width: 32%),
      supplement: "Fig",
    )
  ])
  #place(bottom + center, [
    #figure(
      image("./images/seg.png", width: 32%),
      supplement: "Fig",
    )
  ])
  #place(bottom + right, [
    #figure(
      image("./images/bbox.png", width: 32%),
      supplement: "Fig",
    )
  ])
]

// #centered-slide[
//   = Act 3
//   == Creating Simple Datasets for OMR
// ]

#slide[
  = Act 3 - Creating Simple Datasets for OMR

  #set text(size: 22pt)

  #v(2.5em)

  #place(right, [#align(left,
    [
    - Samples have to be IID
    - Provide intuitive API
    - Create ground truths
    ])
  ])

  #place(bottom + right, [
    #figure(
      image("./images/data_v03_overview.png", width: 32%),
      supplement: "Fig",
    )
  ])

  #place(bottom + left, [
    #set text(size: 14pt)
    ```rust
    // initialize a RandomConfig
    let random_config = RandomConfig::builder()
        .octaves(vec![4, 5])
        .note_types(vec![NoteType::Quarter])
        .stems(vec![Stem::Up, Stem::Down])
        .accidentals_maybe_of(vec![Accidental::Flat, Accidental::Sharp]);

    // create 500 samples and store them to disk
    (0..500).map(|_| {
        let score = Score::builder()
            .add_note(Note::note().random(&mut rng, &random_config)))
            .add_note(Note::note().random(&mut rng, &random_config)));

        let model = RenderModel::from_score(score, MAX_WIDTH);
        model.bitmap();
        model.segmentation_mask(&element_classes);
        model.bounding_boxes(&element_classes);
        // store to disk...
    }
    ```
  ])
]


#centered-slide[
  = Act 4
  == Three Machine Learning Approaches
]

#slide[
  = Act 4 - Three Machine Learning Approaches

  #v(2.5em)

  #set text(size: 20.0pt)

  #align(center, [
    #side-by-side[
      1. Semantic segmentation
      #figure(
        image("./images/seg.png", width: 100%),
        supplement: "Fig",
      )
    ][
      2. Simple regression
      // #v(1.3em)
      #figure(
        image("./images/img.png", width: 100%),
        supplement: "Fig",
      )
    ][
      3. Bounding-box regression
      #figure(
        image("./images/bbox.png", width: 100%),
        supplement: "Fig",
      )
    ]
  ])
]

#slide[
  = Act 4 - Semantic Segmentation

  #v(1em)
  #set text(size: 21pt)

  #align(center, [
    #side-by-side[
      Same distribution as training
      #figure(
        image("./images/seg_v04.png", width: 90%),
        supplement: "Fig",
      )
    ][
      Transfer learning -- different dist.
      #figure(
        image("./images/seg_v04_transfer_01.png", width: 90%),
        supplement: "Fig",
      )
    ]
  ])
]

#slide[
  = Act 4 - Simple Regression

  #set text(size: 21pt)

  #v(1em)

  #side-by-side[
  #v(2.5em)
    - Predict data representation directly
  #set text(size: 16pt)
    ```
Ground Truth: [0 1 0 1 0 0 0 0 0 0 0 0 ...]
Prediction:   [0 1 0 0 1 0 0 0 0 0 0 0 ...]
    ```
  #set text(size: 21pt)

    - hard to #text(c_primary)[learn]
    - hard to #text(c_primary)[generalize]
    - Got stuck in #text(c_primary)[local minima] :(
    - Still promising in real example
  ][
    #v(1em)
    #figure(
      image("./images/reg_v04.png", width: 99%),
      supplement: "Fig",
    )
  ]
]

#slide[
  = Act 4 - Bounding-box Regression

  #v(1em)
  #set text(size: 21pt)

  #align(center, [
    #side-by-side[
      DummyOMRv01
      #figure(
        image("./images/data_v04_overview.png", width: 69%),
        supplement: "Fig",
      )
    ][
      DummyOMRv02
      #figure(
        image("./images/data_v09_overview.png", width: 60%),
        supplement: "Fig",
      )
    ]
  ])
]

#slide[
  = Act 4 - Bounding-box Regression

  #v(1em)
  #set text(size: 21pt)

  #grid(
    columns: (1fr, 1fr, 1fr),
    rows: (auto, auto),
    row-gutter: 0.5em,
    column-gutter: -18.5em,
    [#h(11.5em) v01],
    [#h(10em) v01 + Aug],
    [#h(10em) v02 + Aug],
    figure(
      image("./images/bbox_v05.png", width: 19%),
      supplement: "Fig",
    ),
    figure(
      image("./images/bbox_v05_aug.png", width: 19.5%),
      supplement: "Fig",
    ),
    figure(
      image("./images/bbox_v08_p.png", width: 20%),
      supplement: "Fig",
    ),
  )
]

#slide[
  = Act 4 - Bounding-box Regression

  #v(1em)
  #set text(size: 21pt)

  #grid(
    columns: (1fr, 1fr, 1fr),
    rows: (auto, auto),
    row-gutter: 0.5em,
    column-gutter: -18.5em,
    [#h(11.5em) v01],
    [#h(10em) v01 + Aug],
    [#h(10em) v02 + Aug],
    figure(
      image("./images/bbox_v05_transfer_01.png", width: 19%),
      supplement: "Fig",
    ),
    figure(
      image("./images/bbox_v05_aug_transfer_01.png", width: 19%),
      supplement: "Fig",
    ),
    figure(
      image("./images/bbox_v08_transfer_01.png", width: 19.6%),
      supplement: "Fig",
    ),
  )
]

#slide[
  = Act 4 - Bounding-box Regression

  #v(1em)
  #set text(size: 21pt)

  #grid(
    columns: (1fr, 1fr, 1fr),
    rows: (auto, auto),
    row-gutter: 0.5em,
    column-gutter: -15.5em,
    [#h(10.5em) v01],
    [#h(9em) v01 + Aug],
    [#h(9em) v02 + Aug],
    figure(
      image("./images/bbox_v05_transfer_02.png", width: 29.2%),
      supplement: "Fig",
    ),
    figure(
      image("./images/bbox_v05_aug_transfer_02.png", width: 29%),
      supplement: "Fig",
    ),
    figure(
      image("./images/bbox_v08_transfer_02.png", width: 29%),
      supplement: "Fig",
    ),
  )
]

#slide[
  = Act 4 - Bounding-box Regression

  #v(1em)
  #set text(size: 21pt)

  #side-by-side[
    - Data augmentation is very important
    - Transfer learning possible
    - Bboxes good compromise between

    #h(3em) Generalizable \<--> Parseable

    #v(1em)

    === Next Steps
    - Combine networks
    - Use state-of-the art End2end detection
    - Phrase as seq2seq problem
  ][
    #figure(
      image("./images/bbox_v08.png", width: 68%),
      supplement: "Fig",
    )
  ]
]

#centered-slide[
  = Thank you for listening!
  
  #v(2em)
    Read the whole story at:\
  #text(c_secondary, [
  #link(
    "https://tfachmann.com/music-recognition/",
    [
      https:/\/#text(weight: "bold", [tfachmann])\.com/music-recognition
    ])
  ])
]
