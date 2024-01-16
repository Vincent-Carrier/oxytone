export default function decodeFlags(flags) {
    const pos = {
        n: 'noun',
        v: 'verb',
        t: 'participle',
        a: 'adj.',
        d: 'adv.',
        l: 'article',
        g: 'particle',
        c: 'conj.',
        r: 'prep.',
        p: 'pronoun',
        m: 'numeral',
        i: 'interj.',
        e: 'exclam.',
        u: 'punct.',
        '-': '',
    }[flags[0]];
    const person = {
        1: '1<sup>st</sup> p.',
        2: '2<sup>nd</sup> p.',
        3: '3<sup>rd</sup> p.',
        '-': '',
    }[flags[1]];
    const number = {
        s: 'sing.',
        p: 'plur.',
        d: 'dual',
        '-': '',
    }[flags[2]];
    const tense = {
        p: 'pres.',
        i: 'imperf.',
        r: 'perf.',
        l: 'pluperf.',
        t: 'fut. perf.',
        f: 'fut.',
        a: 'aor.',
        '-': '',
    }[flags[3]];
    const mood = {
        i: '',
        s: 'subj.',
        o: 'opt.',
        n: 'inf.',
        m: 'imp.',
        p: '',
        '-': '',
    }[flags[4]];
    const voice = {
        a: '',
        p: 'passive',
        m: 'middle',
        e: 'medio-passive',
        '-': '',
    }[flags[5]];
    const gender = {
        m: 'm.',
        f: 'f.',
        n: 'n.',
        '-': '',
    }[flags[6]];
    const kase = {
        n: 'nom.',
        g: 'gen.',
        d: 'dat.',
        a: 'acc.',
        v: 'voc.',
        l: 'loc.',
        '-': '',
    }[flags[7]];
    const degree = {
        c: 'comparative',
        s: 'superlative',
    }[flags[8]];
    return [pos, person, number, tense, mood, voice, gender, kase, degree].filter(Boolean).join(' ');
}
//# sourceMappingURL=flags.js.map