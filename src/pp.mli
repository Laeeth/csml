(* This file is released under the terms of an MIT-like license.     *)
(* See the attached LICENSE file.                                    *)
(* Copyright 2016 by LexiFi.                                         *)

(** Simple pretty-printing library. *)

type t
type f = unit -> t
(** A fragment of text.
    Each fragment can be displayed in two modes: linear or multiline.

    The linear mode is initiated by the {!line} combinator. In
    linear mode, all the text is put on a single line. When this
    would produce an horizontal overflow, the multiline mode is
    used instead. Other conditions, like an explicit newline
    instruction, also escape from single line mode.
*)

val linear_length: f -> int
(** Returns [max_int] for a fragment that cannot be printed in linear mode. *)

(** {2 Basic fragments} *)

val empty: f
(** An empty fragment. *)

val str: string -> f
(** Print a string.
    - Linear mode: newline characters \n and \r are ignored.
    - Multiline mode: a character \n (resp. \r) is equivalent to a call to {!newline} (resp. {!force_newline}); all the whitespace characters immediatly following a \n or \r are ignored.

    If the current horizontal location is 0, the current indentation
    level (left margin) is applied before printing the string.

    The string should not contain the character \t. *)

val int: int -> f
(** Print an integer. *)

val float: float -> f
(** Print a float. *)

val ws: f
(** Breakable whitespace.
    - Linear mode: a single whitespace.
    - Multiline mode: a new line.

    This is equivalent to [str "\n "].
*)

val br: f
(** Possible line break.
    - Linear mode: nothing in linear mode.
    - Multiline mode: a new line.

    This is equivalent to [str "\n"].
*)

val newline: f
(** Terminate the current line (print a real \n character) unless
    the current horizontal location is already 0. *)

val force_newline: f
(** Terminate the current line (print a real \n character) even if
    the current horizontal location is already 0. *)

val xloc: f
(** Print the current horizontal location (for debugging). *)

val app: ('a -> string) -> 'a -> f
(** Defined as [fun f x -> str (f x)]. *)

(** {2 Assembling fragments} *)

val conc: f -> f -> f
(** Concatenate two fragments. *)

val all: f list -> f
(** Concatenate many fragments. *)

val list: ?sep:f -> ('a -> f) -> 'a list -> f
(** Print a list with an optional separator between elements. *)

val listi: ?sep:f -> (int -> 'a -> f) -> 'a list -> f
(** Print a list with an optional separator between elements.
    The function to print each element also takes the elements' rank
    (starting from 0). *)

val seq: ?sep:f -> (int -> f) -> int -> int -> f
(** [seq f i j] Print a sequence of things generated by integers
    from [i..(j-1)]. *)

val opt: ('a -> f) -> 'a option -> f

(** {2 Controlling the layout} *)

val either: f -> f -> f
(** [either x y] behaves as [x] in linear mode and as [y] in multiline mode. *)

val indent: int -> f -> f
(** [indent n x]
    - Linear mode: same as [x].
    - Multiline mode: print [x] in a context where the indentation level has been increased by [n]. *)

val indent_relative: int -> f -> f
(** [indent_relative n l]
    - Linear mode: same as [x].
    - Multiline mode: print [x] in a context where the indentation level is defined as the current horizontal position plus [n]. *)

val line: f -> f
(** Print its first argument in linear mode if possible, otherwise
    in multiline mode. *)

val force_multiline: f
(** Escape from linear mode. Does not print anything. *)

val force_linear: f -> f
(** Print its argument in linear mode even if it would overflow
    horizontally. If the argument contains an instruction that
    prevent linear mode, such as {!newline} or {!force_multiline},
    then this operator has no effect. *)


(** {2 Useful operators} *)

module Operators:
sig
  val (~~): ('a, unit, t, f) format4 -> 'a (** Synonym for {!Mlfi_pp.printf}. *)

  val (//): f -> f -> f (** Synonym for {!Mlfi_pp.either}. *)

  val (///): string -> string -> f (** [x///y] is aynonym for [!x // !y]. *)

  val (++): f -> f -> f (** Synonym for {!Mlfi_pp.conc}. *)
end

(** {2 Printing fragments} **)

type pp_info = {
  width: int; (** The maximum width of the output for linear mode. *)
  indent: int; (** The initial indentation. *)
}

type pp_fragment = pp_info * f

val to_function: (string -> unit) -> pp_fragment -> unit
val to_string: pp_fragment -> string
val to_channel: out_channel -> pp_fragment -> unit
val to_buffer: Buffer.t -> pp_fragment -> unit
val to_file: string -> pp_fragment -> unit
val print: Format.formatter -> pp_fragment -> unit

(** {2 Printf formatting} *)

val printf: ('a, unit, t, f) format4 -> 'a
(** Printf-like function.

    In addition to [Printf.printf]'s conversion specifications
    (introduced by the character %), {!Mlfi_pp.printf} recognizes
    special formatting instruction introduced by the character @.

    - [ @\[...@\] ]: the fragment [...]
    is wrapped in a call to [Mlfi_pp.indent 2].

    - [ @<...@> ]: the fragment [...] is wrapped
    in a call to [Mlfi_pp.line].

    The combination [@@] produces a single [@] character.
    If [@] is followed by a character different from
    [@], [\[], [\]], [<], [>], [(], [)] and [|], it is not interpeted
    in a special way (so it is not necessary to escape it).

    Note that the layout commands introduced by [@] must be
    well-balanced and contained in a single format string.
*)
