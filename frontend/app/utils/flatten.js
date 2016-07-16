// Credit: https://ponyfoo.com/articles/proposal-draft-for-flatten-and-flatmap
export default function flatten(list) {
  return list.reduce((a, b) => (Array.isArray(b) ? a.push(...flatten(b)) : a.push(b), a), []);
}
