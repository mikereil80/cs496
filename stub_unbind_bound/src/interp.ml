open Ast
open Ds

let rec apply_proc v1 v2 : exp_val ea_result = (* type equals env -> exp_val result, type synonyms *)
    match v1 with
    | ProcVal(id,e,en) -> return en >>+
                          extend_env id v2 >>+ 
                          eval_expr e
    | _ -> error "Expected a closure"

and

let rec eval_expr : expr -> exp_val ea_result = fun e ->
  match e with
  | Int(n) ->
    return @@ NumVal n
  | Var(id) ->
    apply_env id
  | Add(e1,e2) ->
    eval_expr e1 >>=
    int_of_numVal >>= fun n1 ->
    eval_expr e2 >>=
    int_of_numVal >>= fun n2 ->
    return @@ NumVal (n1+n2)
  | Sub(e1,e2) ->
    eval_expr e1 >>=
    int_of_numVal >>= fun n1 ->
    eval_expr e2 >>=
    int_of_numVal >>= fun n2 ->
    return @@ NumVal (n1-n2)
  | Mul(e1,e2) ->
    eval_expr e1 >>=
    int_of_numVal >>= fun n1 ->
    eval_expr e2 >>=
    int_of_numVal >>= fun n2 ->
    return @@ NumVal (n1*n2)
  | Div(e1,e2) ->
    eval_expr e1 >>=
    int_of_numVal >>= fun n1 ->
    eval_expr e2 >>=
    int_of_numVal >>= fun n2 ->
    if n2==0
    then error "Division by zero"
    else return @@ NumVal (n1/n2)
  | Let(id,def,body) ->
    eval_expr def >>= 
    extend_env id >>+
    eval_expr body 
  | ITE(e1,e2,e3) ->
    eval_expr e1 >>=
    bool_of_boolVal >>= fun b ->
    if b 
    then eval_expr e2
    else eval_expr e3
  | IsZero(e) ->
    eval_expr e >>=
    int_of_numVal >>= fun n ->
    return @@ BoolVal (n = 0)
  | Cons(e1,e2) ->
    eval_expr e1 >>= fun v ->
    eval_expr e2 >>=
    list_of_listVal >>= fun vs ->
    return (ListVal(v::vs))
  | Unbind(id,e) -> (* will need >>+ *)
    apply_env id >>= fun _ ->
    unbind id >>+ (* need to define unbind *)
    eval_expr e 
  | IsBound(id) ->
    find id
  | Proc(id,e) ->
    lookup_env >>= fun env ->
    return (ProcVal(id,e,env))
  | App(e1,e2) ->
    eval_expr e1 >>= fun v1 ->
    eval_expr e2 >>= fun v2 ->
    apply_proc v1 v2
  | Record(fs) ->
    sequence(List.map(fun (id,e) -> eval_expr e) fs) >>= fun vs ->
    return (RecordVal (add_fields fs vs)) (* Remember sequence for the list fixing *)
  | Proj(e,id) ->
    eval_expr e >>=
    record_of_recordVal >>= fun vs ->
    match List.assoc_opt id fvs with
    | None -> error "field does not exist"
    | Some v -> return v
  | Letrec(id,par,body,target) ->
    extend_env_rec id par body >>+
    eval_expr target
  | Debug(_e) ->
    string_of_env >>= fun str ->
    print_endline str; 
    return @@ UnitVal
  | _ -> error "Not implemented yet!"

let eval_prog (AProg e) = eval_expr e 


(* Parse a string into an ast *)
let parse s =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.prog Lexer.read lexbuf in
  ast


(* Interpret an expression *)
let interp (s:string) : exp_val result =
  let c = s |> parse |> eval_prog
  in run c

  (* 
  s:string 
  parse s: expr 
  eval_prog (parse s) : exp_val ea_result
  c: exp_val ea_result
  c: env  -> exp_val result
  *)

let rec eval_expr : expr -> exp_val ea_result = fun e ->
  exp_val ea_result
  env -> exp_val result



