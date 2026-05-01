#!/usr/bin/env python3
"""One-off generator — writes assets/web/projects-detail-copy.json"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "web" / "projects-detail-copy.json"

COPY = {
    "AKIKI": "\n\n".join(
        [
            '"These Are Not Just Hands" is a project rooted in perception, what is seen on the surface versus what carries meaning beneath it.',
            'The concept began with René Magritte\'s "Ceci n\'est pas une pipe," evolving into a reflection on how Aki engages with creation, not as appearance, but as depth.',
            "Where the world sees form, Aki sees foundation.",
            "These are not just hands. They are the hands that built, that waited, that shaped, and that loved through the act of making. They are not a detail within the story, they are the story itself.",
            "The project becomes a dedication to this invisible layer of craft and intention, where every gesture carries history.",
        ]
    ),
    "AKI": "\n\n".join(
        [
            "Aki Lounge is a creation of Akiki's second generation, an extension of the brand into a dedicated space for experience, ritual, and refinement.",
            "Built as a cigar lounge within Akiki, it is defined by an uncompromising attention to detail and a commitment to elevated sensory experiences. Every element is considered, from palette to materiality, from atmosphere to rhythm.",
            "We spent time within the space, returning repeatedly to observe, to listen, and to experience it as it shifts with time. Each visit revealed something different, not through change, but through depth. It became a practice in noticing.",
            "The lounge invites a different way of seeing and feeling. It is not only about luxury, but about perception, how taste, color, sound, and presence can be experienced more deliberately.",
            "From this immersion came the creation of three short projects, shaped by the idea of Aki as something you do not simply visit, but something you return to in thought. A space that lingers, and quietly calls you back.",
        ]
    ),
    "BEIT TRAD": "\n\n".join(
        [
            "Beit Trad is a place we continuously return to, not as a location, but as a state of pause.",
            "The project is rooted in the relationship between time and space. At Beit Trad, time does not move in a conventional way. It suspends. It softens. It creates room for a different kind of presence, where detachment from the outside becomes natural.",
            "Each space within it carries its own identity, its own palette, its own character. Moving through it feels like moving through shifting atmospheres rather than defined rooms.",
            "When approaching the project, it was difficult to define where to begin. Beit Trad resists explanation. No film can fully translate what it holds; it can only suggest it. The decision was therefore to follow intuition. To move with observation rather than structure, and to let the camera respond to what was felt rather than what was planned.",
            "What emerged is a reflection of that experience. A quiet attempt to translate a place that ultimately can only be understood in person, through time spent within it.",
        ]
    ),
    "BOKJA": "\n\n".join(
        [
            "Our collaboration with Bokja began in 2023 and has since grown into an ongoing creative dialogue.",
            "Bokja carries a distinct character, one that is playful, colorful, and unapologetically expressive. In many ways, it stands in contrast to our own language, and it is precisely this tension that makes the collaboration meaningful. It allows for a creative space where exploration feels open and unrestricted.",
            "At its core, Bokja is a storytelling brand. Each piece, whether a couch, a garment, or a tapestry, holds a narrative embedded within its surface. Their work translates stories through design, in the same way we approach storytelling through image and film.",
            "Our role has been to interpret and extend these narratives, to articulate the ideas and poetry behind each collection across different moments and seasons. It is a process built on alignment, trust, and a shared sensitivity to meaning.",
            "Being part of Bokja's journey as ongoing storytelling partners is something we value deeply, both creatively and personally.",
        ]
    ),
    "ELISSAR": "\n\n".join(
        [
            "Elissar is often introduced as an interior designer, but that definition only captures the surface.",
            "The project began with a shared understanding that her work, and her way of thinking, cannot be reduced to simple answers. There is a clear resistance to the expected questions, the need to define, categorize, or explain in a conventional way.",
            "This led to a different approach. Rather than creating a traditional profile, the intention was to build something that reflects her depth through conversation rather than description.",
            "The project became a response to those first-layer questions. A piece that holds her perspective, her sensitivities, and her way of seeing, without simplifying them.",
            "It stands as something she can return to and share, not as an explanation, but as an experience of who she is, on her own terms.",
        ]
    ),
    "IRRELEVANT": "\n\n".join(
        [
            "Irrelevant is a brand shaped by contrast, born from a moment where collapse gave way to creation.",
            "Following our first collaboration, which explored what Irrelevant is, this project responds to a different question: who is Irrelevant. It turns toward the person behind the brand, placing the focus on the individual rather than the product.",
            "The project revolves around this perspective, seeking to highlight his way of thinking, his way of seeing, and his relationship to the world around him.",
            "Rather than defining the brand through description, it approaches it through mindset. What emerges is a portrait where Irrelevant is understood as an extension of its creator, shaped by his perception and his point of view.",
        ]
    ),
    "KATARINA": "\n\n".join(
        [
            "Meeting Katarina and witnessing her process closely shaped the direction of this project.",
            "Spending extended time with her revealed a way of thinking where each piece begins with an idea, a story, and a clear intention. This led to the creation of a series of 18 short projects, each one reflecting the narrative behind a specific piece.",
            "Her work goes beyond material value. Each creation carries its own character, its own movement, and a sense of play that defines how it exists and how it is experienced. No two pieces feel alike; each one holds a distinct identity.",
            "The approach was to translate this diversity into a visual language that remains light, precise, and attentive to detail, allowing every piece to exist on its own terms.",
            "What emerges is a series that reflects not only the objects themselves, but the thought and imagination behind them. An experience that begins visually, but is only fully understood when encountered in person.",
        ]
    ),
    "MJ": "\n\n".join(
        [
            "Meeting Marie Jo introduced an immediate sense of contrast. A mezzo-soprano opera singer and a lawyer, held together with an ease that felt almost unreal.",
            "What first appeared as two opposing worlds gradually revealed unexpected parallels. Discipline, precision, performance, and control exist in both, each demanding a similar level of presence and commitment.",
            "The project developed from this intersection. Her story felt inherently cinematic, leading to an approach shaped around that intuition. Rather than attempting to contain it within a single narrative, we chose to treat it as the beginning of one.",
            "The result is constructed as a trailer, a glimpse into a larger story that reflects the duality she embodies. A way of introducing her world without reducing it, and allowing both sides of her identity to exist in dialogue.",
        ]
    ),
    "NAGGIAR ARTIST": "\n\n".join(
        [
            "Naggiar approached this project with a clear vision and high expectations, set within a limited timeframe. It was a demanding context, but one driven by a strong and ambitious idea.",
            "The project marked the opening of their fab lab, introduced through their participation in We Design Beirut. As part of this initiative, eleven artists were invited to create original pieces within the space, each contributing to the identity of the lab and its launch.",
            "Our role was to document each artist and their work, capturing both the process and the thinking behind every piece. Each project required its own narrative, shaped through direct exchange with the artists and an understanding of their individual approaches.",
            "The result is a series of portraits that reflect not only the final works, but the time, experimentation, and intention behind them.",
            "It remains a project defined by its intensity, its collaborative nature, and the encounter with a diverse group of artists, each bringing a distinct voice into a shared space.",
        ]
    ),
    "NAGGIAR FILM": "\n\n".join(
        [
            "This project approaches Naggiar as a brand through a broader question: where does its story begin.",
            "With a history spanning more than a century, the answer could not be rooted in a single moment. Instead, the starting point became the material itself. Metal, as both foundation and language.",
            "The film builds on the idea that metal exists everywhere, shaping the world in visible and invisible ways. It is present in structures that sustain cities, in tools that enable creation, in music, in medicine, and in the smallest functional details of everyday life.",
            "From this perspective, Naggiar is positioned within a larger narrative. One that does not begin with the brand, but with the element that makes it possible.",
            "The project becomes a reflection on this relationship. If metal did not exist, neither would Naggiar. Yet through its work, Naggiar gives form to it, shaping it with intention and continuity.",
            "A story that celebrates metal, giving it meaning, scale, and time.",
        ]
    ),
    "OIL & GAZ": "\n\n".join(
        [
            "Our collaboration with Oil & Gas is defined by a shared approach to creativity, one where ideas are not reduced, but pushed further.",
            "From the beginning, there was a clear alignment. The more ambitious and unconventional the direction, the more it was embraced as a challenge. This created a dynamic where limitations became less relevant, and exploration became central to the process.",
            "The project evolved into a complete rethinking of the brand's identity. Not as a fixed system, but as something that could expand, shift, and respond to each new campaign.",
            "Working together since 2025, the relationship has been built on trust and continuity. Each project becoming an extension of the previous one, while opening new directions.",
            "What defines this collaboration is a sense of possibility. An understanding that with the right partnership, ideas can move beyond expectation and take on forms that feel both natural and unexpected.",
        ]
    ),
    "ORIENT": "\n\n".join(
        [
            "The Orient Ramadan campaign was developed under significant time constraints, with only one week of preparation from the moment of briefing. Despite the pressure, the project became a testament to what a focused and aligned team can achieve, where time becomes secondary to clarity of idea and execution.",
            "The concept began with the word itself: orient. Understood as both direction and action, it became a call to reorient, to return to reflection and to realign with tradition during a moment of spiritual significance.",
            "Ramadan, as a period of pause and introspection, shaped the narrative direction. The campaign embraced a sense of richness and intensity, reflecting the emotional and cultural depth of the season.",
            "At its core, the story was built around duality. Two opposing forces, the moon and the sun, guiding the narrative toward a final moment of convergence, where they come together at iftar.",
            "The project follows this journey from beginning to end as a gradual movement toward alignment, tradition, and shared presence.",
        ]
    ),
    "POP UP": "\n\n".join(
        [
            "Pop-up is one of our earliest collaborators, a partner we began working with in 2021, before the studio formally became Not So Civilised.",
            "The relationship started with a series of visual content for their social platforms and gradually evolved into full campaign work over the years. It has been a long-standing collaboration built on continuity, trust, and a shared understanding of storytelling through image.",
            'One of the most recent projects was a Christmas campaign titled "The Christmas Wish List," a series of three films designed to reflect the idea that everything one might wish for can be found at Pop-up.',
            "Across years of work together, the collaboration has remained consistent in its intent: to translate seasonal moments and brand identity into simple, clear narratives.",
            "It is an ongoing partnership, one that continues to evolve with time.",
        ]
    ),
    "SAMI": "\n\n".join(
        [
            "Sami is a creative director with nearly 40 years of experience in the industry, and the founder of his own boutique studio, Phenomena.",
            "When he approached us to create a personal film, the challenge was immediate: how do you visually interpret someone who already shapes visual worlds for a living.",
            "The process began, as it often does, with a recorded conversation. A full Q&A session that became the foundation of the narrative structure, allowing the story to emerge from his own words rather than an external script.",
            "From there, the film was built through a combination of observational footage within his office and subtle layers of animation, reflecting a more playful dimension of his personality.",
            "The result reveals a contrast at the core of his practice: a highly experienced creative director, and at the same time, an individual who retains a sense of curiosity and lightness that continues to shape his work.",
        ]
    ),
    "SARA'S BAG": "\n\n".join(
        [
            "Our journey with Sarah's Bag began in the summer of 2025, shaped by a brand that immediately evokes Beirut, its light, its energy, and its sense of place.",
            "Stepping into the space feels less like entering a store and more like entering a living archive. Each piece is suspended as if it carries its own memory, its own voice, waiting to be heard. The space itself feels responsive, as though it holds stories within its walls.",
            "Sarah's approach is defined by this same sensitivity. Her work is not centered on product alone, but on narrative, poetry, and the human context behind each creation. Every collection begins with observation, inspired by people, places, and lived moments.",
            'Working with her is an ongoing exchange of ideas rooted in storytelling. From "Sarah\'s Guide to Beirut" to "In Her Hands," each project has been an extension of this vision.',
            "What connects them all is a shared intention: to translate experience into form, and to preserve the emotional landscape that shapes each piece.",
        ]
    ),
    "SARISTIQUE": "\n\n".join(
        [
            "Saritistique is not a brand, but a creative force within Not So Civilised, working at the intersection of fashion, concept, and visual storytelling. Our collaboration spans from 2022 to 2025, shaped by an evolving visual language and a shared approach to fashion as a medium for ideas.",
            "Over My Dead Body, the most recent project, is a fashion film developed alongside a collection of the same name. Created during a period of instability, it reflects a state where the line between being alive and being gone becomes unclear — where presence can feel empty, and absence can still carry weight.",
            "The process began from stillness. Imagery formed through fragments, observation, repetition, memory — building a visual language rooted in tension. Presented as her first runway show, it also became her last. The concept extended into reality: a beginning that was also an ending. As Saritistique stepped away from fashion to continue within Not So Civilised as its creative director, the idea at the core of the work became tangible — how something can end while still existing in another form.",
        ]
    ),
    "BESH": "\n\n".join(
        [
            "Creative direction and moving image for Besh — bespoke collaboration shaped around the brand's presence on screen.",
            "Campaign and execution developed as its own process, timeline, and team.",
        ]
    ),
    "SOAR": "\n\n".join(
        [
            "Brand film — motion, ascent, and distilled narrative.",
            "Visual storytelling built around trajectory and tone.",
        ]
    ),
    "STEAKBAR SUSHI": "\n\n".join(
        [
            "Campaign and atmosphere — the dining experience in frame.",
            "Content shaped for appetite, craft, and the energy of the room.",
        ]
    ),
}

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps(COPY, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {OUT} ({len(COPY)} keys)")
