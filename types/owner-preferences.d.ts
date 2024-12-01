import { UID } from './general';

export type TPalate = {
  bg: string,
  text: string,

  h1: string,
  h2: string,
  h3: string,
  h4: string,

  link: string,
  linkActive: string,
  linkHover: string,
  linkDecoration: string,

  primaryBg: string,
  primaryTxt: string,
  primaryBorder: string,

  secondaryBg: string,
  secondaryTxt: string,
  secondaryBorder: string,

  tertiaryBg: string,
  tertiaryTxt: string,
  tertiaryBorder: string,

  auxilliaryBg: string,
  auxilliaryTxt: string,
  auxilliaryBorder: string,
}

export type TOwner = {
  id: UID,
  gameID: UID|null,
  Scheme: TPalate|null,
  darkMode: boolean|null,
  fontAdjust: number,
  lastURL: string,
  playerID: UID,
  defaultPermissionsMode: number
}
