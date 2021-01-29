;;; meow-var.el --- Meow variables
;;; -*- lexical-binding: t -*-

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;; Internal variables and customizable variables.

;;; Code:

(defgroup meow nil
  "Custom group for meow."
  :group 'meow-module)

;; Behaivors

(defcustom meow-expand-exclude-mode-list
  '(markdown-mode org-mode)
  "A list of major modes where after-command-expand should be disabled."
  :group 'meow
  :type 'list)

(defcustom meow-selection-command-fallback
  '((meow-replace . meow-replace-char)
    (meow-change . meow-change-char)
    (meow-save . meow-save-char)
    (meow-kill . meow-C-k)
    (meow-delete . meow-C-d)
    (meow-cancel-selection . meow-keyboard-quit))
  "Fallback commands for selection commands when there's no available selection."
  :group 'meow
  :type 'list)

(defcustom meow-replace-state-name-list
  '((normal . "NORMAL")
    (motion . "MOTION")
    (keypad . "KEYPAD")
    (insert . "INSERT"))
  "A list of mappings for how to display state in indicator."
  :group 'meow
  :type 'list)

(defcustom meow-select-on-exit nil
  "If we activate region when exit INSERT mode.

If the value is t, a region will be activated.
Its range is from current point to the point where we enter INSERT mode."
  :group 'meow
  :type 'boolean)

(defcustom meow-expand-hint-remove-delay 1.0
  "The delay before the position hint disappear."
  :group 'meow
  :type 'integer)

(defcustom meow-keypad-message t
  "If log keypad message in minibuffer."
  :group 'meow
  :type 'boolean)

(defcustom meow-char-thing-table
  '((?r . round)
    (?s . square)
    (?c . curly)
    (?g . string)
    (?e . symbol)
    (?w . window)
    (?b . buffer)
    (?p . paragraph)
    (?l . line)
    (?d . defun)
    (?i . indent))
  "Mapping from char to thing."
  :group 'meow
  :type 'list)

(defcustom meow-keypad-describe-delay
  0.5
  "The delay seconds before popup keybinding descriptions."
  :group 'meow
  :type 'float)

(defcustom meow-grab-fill-commands
  '(meow-query-replace meow-query-replace-regexp)
  "A list of commands that meow will auto fill with grabed content."
  :group 'meow
  :type 'list)

(defcustom meow-grab-delimiters
  '("▶" . "◀")
  "Delimiters for grab selection."
  :group 'meow
  :type 'list)

(defcustom meow-grab-indicator
  '("[G]" . "[g]")
  "Indicator for meow grab.

Car for buffer have grab selection, Cdr for buffer use grab selection.")

(defvar meow-keypad-describe-keymap-function 'meow-describe-keymap
  "The function used to describe (KEYMAP) during keypad execution.

To integrate WhichKey-like features with keypad.
Currently, keypad are not work well with which-key,
so Meow ships a default `meow-describe-keymap'.
Use (setq meow-keypad-describe-keymap-function 'nil) to disable popup.")

;; Cursor types

(defvar meow-cursor-type-default 'box)
(defvar meow-cursor-type-normal 'box)
(defvar meow-cursor-type-motion 'box)
(defvar meow-cursor-type-insert '(bar . 4))
(defvar meow-cursor-type-keypad 'hollow)

;; Keypad states

(defvar meow--keypad-meta-prefix ?m)
(defvar meow--keypad-both-prefix ?g)
(defvar meow--keypad-literal-prefix 32)
(defvar meow--keypad-keys nil)
(defvar meow--keypad-previous-state nil)

(defvar meow--prefix-arg nil)
(defvar meow--use-literal nil)
(defvar meow--use-meta nil)
(defvar meow--use-both nil)

;;; KBD Macros
;; We use kbd macro instead of direct command/function invocation,
;; this allow us not hard code the command/function name.
;;
;; The benefit is an out-of-box integration support for other plugins, like: paredit.
;;
;; NOTE: meow is assuming user not modify vanilla Emacs keybindings, otherwise extra complexity will be introduced.

(defvar meow--kbd-undo "C-/"
  "KBD macro for command `undo'.")

(defvar meow--kbd-keyboard-quit "C-g"
  "KBD macro for command `keyboard-quit'.")

(defvar meow--kbd-find-ref "M-."
  "KBD macro for command `xref-find-definitions'.")

(defvar meow--kbd-pop-marker "M-,"
  "KBD macro for command `xref-pop-marker-stack'.")

(defvar meow--kbd-comment "M-;"
  "KBD macro for comment command.")

(defvar meow--kbd-kill-line "C-k"
  "KBD macro for command `kill-line'.")

(defvar meow--kbd-kill-whole-line "<C-S-backspace>"
  "KBD macro for command `kill-whole-line'.")

(defvar meow--kbd-delete-char "C-d"
  "KBD macro for command `delete-char'.")

(defvar meow--kbd-yank "C-y"
  "KBD macro for command `yank'.")

(defvar meow--kbd-yank-pop "M-y"
  "KBD macro for command `yank-pop'.")

(defvar meow--kbd-kill-ring-save "M-w"
  "KBD macro for command `kill-ring-save'.")

(defvar meow--kbd-kill-region "C-w"
  "KBD macro for command `kill-region'.")

(defvar meow--kbd-back-to-indentation "M-m"
  "KBD macro for command `back-to-indentation'.")

(defvar meow--kbd-indent-region "C-M-\\"
  "KBD macro for command `indent-region'.")

(defvar meow--kbd-delete-indentation "M-^"
  "KBD macro for command `delete-indentation'.")

(defvar meow--kbd-forward-slurp "C-)"
  "KBD macro for command forward slurp.")

(defvar meow--kbd-backward-slurp "C-("
  "KBD macro for command backward slurp.")

(defvar meow--kbd-forward-barf "C-}"
  "KBD macro for command forward barf.")

(defvar meow--kbd-backward-barf "C-{"
  "KBD macro for command backward barf.")

(defvar meow--kbd-scoll-up "C-v"
  "KBD macro for command `scroll-up'.")

(defvar meow--kbd-scoll-down "M-v"
  "KBD macro for command `scroll-down'.")

(defvar meow--kbd-just-one-space "M-SPC"
  "KBD macro for command `just-one-space.")

(defvar meow--kbd-wrap-round "M-("
  "KBD macro for command wrap round.")

(defvar meow--kbd-wrap-square "M-["
  "KBD macro for command wrap square.")

(defvar meow--kbd-wrap-curly "M-{"
  "KBD macro for command wrap curly.")

(defvar meow--kbd-wrap-string "M-\""
  "KBD macro for command wrap string.")

(defvar meow--kbd-excute-extended-command "M-x"
  "KBD macro for command `execute-extended-command'.")

(defvar meow--kbd-transpose-sexp "C-M-t"
  "KBD macro for command transpose sexp.")

(defvar meow--kbd-split-sexp "M-S"
  "KBD macro for command split sexp.")

(defvar meow--kbd-splice-sexp "M-s"
  "KBD macro for command splice sexp.")

(defvar meow--kbd-raise-sexp "M-r"
  "KBD macro for command raise sexp.")

(defvar meow--kbd-join-sexp "M-J"
  "KBD macro for command join sexp.")

(defvar meow--kbd-eval-last-exp "C-x C-e"
  "KBD macro for command eval last exp.")

(defvar meow--kbd-query-replace-regexp "C-M-%"
  "KBD macro for command `query-replace-regexp'.")

(defvar meow--kbd-query-replace "M-%"
  "KBD macro for command `query-replace'.")

(defvar meow--kbd-forward-line "C-n"
  "KBD macro for command `forward-line'.")

(defvar meow--kbd-backward-line "C-p"
  "KBD macro for command `backward-line'.")

(defvar meow--kbd-search-forward-regexp "C-M-s"
  "KBD macro for command `search-forward-regexp'.")

(defvar meow--kbd-search-backward-regexp "C-M-r"
  "KBD macro for command `search-backward-regexp'.")

(defvar-local meow--indicator nil
  "Indicator for current buffer.")

(defvar-local meow--selection nil
  "Current selection.

Has a structure of (sel-type point mark).")

;;; Declare modes we need to activate normal state as default
;;; Other modes will use motion state as default.

(defvar meow-normal-state-mode-list
  '(fundamental-mode
    text-mode
    prog-mode
    conf-mode
    cider-repl-mode
    eshell-mode
    vterm-mode
    json-mode
    wdired-mode
    deft-mode
    pass-view-mode
    telega-chat-mode
    restclient-mode
    help-mode
    deadgrep-edit-mode
    mix-mode
    py-shell-mode)
  "A list of modes should enable normal state.")

(defvar meow-auto-switch-exclude-mode-list
  '(ripgrep-search-mode
    ivy-occur-grep-mode)
  "A list of modes don't allow auto switch state.")

;;; Search

(defvar meow--recent-searches nil
  "A list of recent searches.")

;;; Hooks

(defvar meow-switch-state-hook nil
  "Hooks run when switching state.")

;;; Internal variables

(defvar-local meow--temp-normal nil
  "If we are in temporary normal state. ")

(defvar meow--selection-history nil
  "The history of selection.")

(defvar meow--expand-nav-function nil
  "Current expand nav function.")

(defvar meow--visual-command nil
  "Current command to highlight.")

(defvar meow--keypad-this-command nil
  "Command name for current keypad execution.")

(defvar meow--expanding-p nil
  "If we are expanding.")

(defvar meow--keypad-keymap-description-activated nil
  "If KEYPAD keymap description is already activated.")

(defvar meow--motion-overwrite-keys
  '(" ")
  "A list of keybindings to overwrite in MOTION state.")

(defvar-local meow--insert-pos nil
  "The position where we enter INSERT state.")

(defvar meow-full-width-number-position-chars
  '((0 . "０")
    (1 . "１")
    (2 . "２")
    (3 . "３")
    (4 . "４")
    (5 . "５")
    (6 . "６")
    (7 . "７")
    (8 . "８")
    (9 . "９"))
  "Map number to full-width character.")

(defvar meow-cheatsheet-ellipsis "…"
  "Ellipsis character used in cheatsheet.")

(defvar meow-command-to-short-name-list
  '((meow-expand-0 . "ex →0")
    (meow-expand-1 . "ex →1")
    (meow-expand-2 . "ex →2")
    (meow-expand-3 . "ex →3")
    (meow-expand-4 . "ex →4")
    (meow-expand-5 . "ex →5")
    (meow-expand-6 . "ex →6")
    (meow-expand-7 . "ex →7")
    (meow-expand-8 . "ex →8")
    (meow-expand-9 . "ex →9")
    (digit-argument . "num-arg")
    (meow-inner-of-thing . "←thing→")
    (meow-bounds-of-thing . "[thing]")
    (meow-beginning-of-thing . "←thing")
    (meow-end-of-thing . "thing→")
    (meow-reverse . "reverse")
    (meow-prev . "↑")
    (meow-prev-expand . "ex ↑")
    (meow-next . "↓")
    (meow-next-expand . "ex ↓")
    (meow-head . "←")
    (meow-head-expand . "ex ←")
    (meow-tail . "→")
    (meow-tail-expand . "ex →")
    (meow-left . "←")
    (meow-left-expand . "ex ←")
    (meow-right . "→")
    (meow-right-expand . "ex →")
    (meow-yank . "yank")
    (meow-find . "find")
    (meow-find-expand . "ex find")
    (meow-till . "till")
    (meow-till-expand . "ex till")
    (meow-keyboard-quit . "C-g")
    (meow-cancel-selection . "quit sel")
    (meow-change . "chg")
    (meow-change-save . "chg-save")
    (meow-replace . "rep")
    (meow-replace-save . "rep-save")
    (meow-append . "append")
    (meow-open-below . "open ↓")
    (meow-insert . "insert")
    (meow-open-above . "open ↑")
    (meow-block . "block")
    (meow-block-expand . "ex block")
    (meow-line . "line")
    (meow-delete . "del")
    (meow-search . "search")
    (meow-pop-search . "popsearch")
    (negative-argument . "neg-arg")
    (meow-quit . "quit")
    (meow-join . "join")
    (meow-kill . "kill")
    (meow-save . "save")
    (meow-next-word . "word→")
    (meow-next-symbol . "sym→")
    (meow-back-word . "←word")
    (meow-back-symbol . "←sym")
    (meow-pop-all-selection . "pop-sels")
    (meow-pop-selection . "pop-sel")
    (meow-mark-word . "←word→")
    (meow-mark-symbol . "←sym→")
    (meow-visit . "visit"))
  "A list of (command . short-name)")

(defvar meow--kmacro-range nil
  "The (beg-line-number . end-line-number) when `meow-start-kmacro' is called.")

;;; Backup variables

(defvar meow--backup-var-delete-activae-region nil
  "The backup for `delete-active-region'.

It is used to restore its value when disable `meow'.")

(provide 'meow-var)
;;; meow-var.el ends here
