export type TCustomTheme = {
    bgColor: string,
    color: string,
    font: string,
}

export type TAppState = {
    /**
     * @property Font scale adjustment for users who want to increase
     *           or decrease the font size
     */
    fontAdjust: number,

    /**
     * @property Whether or not the user wants to use dark mode. If
     *           boolean, user has made a conscious decesion to use
     *           dark mode
     */
    darkMode: boolean|null,

    /**
     * @property settings for custom theme if user has chosen to set
     *           their own.
     *           > __Note:__ custom theme overrides dark mode
     *           >           preferences, however if darkmode is
     *           >           boolean when custom theme is set,
     *           >           light/dark mode theme will be used as
     *           >           the starting point for theme
     *           >           customisation.
     */
    customTheme: TCustomTheme|null,

    /**
     * @property URL path for the last link the user clicked on.
     *           `lastPath` is used when app is initially loaded
     *           (without any path) to determine the apps state.
     *           if app is open in multiple tabs `lastPath` can be
     *           updated from all tab but will not impact any other
     *           tab
     */
    lastPath: string,

    /**
     * @property ID of game currently being played
     */
    gameID: string | null,
};
