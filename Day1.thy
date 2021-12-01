theory Day1
  imports
    Main
    "HOL-Library.Code_Target_Numeral"
begin

definition increases :: "nat list \<Rightarrow> nat set" where
  "increases xs = {i. xs ! i < xs ! Suc i \<and> Suc i < length xs}"

fun count_increases :: "nat list \<Rightarrow> nat" where
  "count_increases [] = 0" |
  "count_increases [x] = 0" |
  "count_increases (x # y # ys) =
   (if x < y then Suc (count_increases (y # ys))
    else count_increases (y # ys))"

lemma finite_increases[simp]:
  "finite (increases xs)"
proof (rule finite_subset)
  show "increases xs \<subseteq> {i. i < length xs}"
    by (auto simp: increases_def)
  show "finite {i. i < length xs}"
    by auto
qed

theorem count_increases_correct:
  "count_increases xs = card (increases xs)"
proof (induction xs rule: count_increases.induct)
  case (3 x y ys)
  then have "count_increases (y # ys) = card (increases (y # ys))"
    by auto
  moreover have "increases (x # y # ys) = {i. (x # y # ys) ! i < (x # y # ys) ! Suc i \<and> i = 0} \<union> Suc ` increases (y # ys)" (is "?lhs = ?rhs")
  proof (intro set_eqI)
    fix i
    show "i \<in> ?lhs \<longleftrightarrow> i \<in> ?rhs"
      apply (cases i)
      by (auto simp: increases_def)
  qed
  moreover have "{i. (x # y # ys) ! i < (x # y # ys) ! Suc i \<and> i = 0} = (if x < y then {0} else {})"
    by auto
  ultimately show "count_increases (x # y # ys) = card (increases (x # y # ys))"
    by (simp add: card_image)
qed (auto simp: increases_def)

fun count_increases' :: "nat list \<Rightarrow> nat \<Rightarrow> nat" where
  "count_increases' [] acc = acc" |
  "count_increases' [x] acc = acc" |
  "count_increases' (x # y # ys) acc =
   count_increases' (y # ys) (if x < y then Suc acc else acc)"

lemma count_increases'_refine:
  "count_increases' xs acc = acc + count_increases xs"
  by (induction xs arbitrary: acc rule: count_increases.induct) auto

fun part1 :: "nat list \<Rightarrow> nat" where
  "part1 xs = count_increases' xs 0"

theorem part1_correct:
  "part1 xs = card (increases xs)"
  by (simp add: count_increases'_refine count_increases_correct)

export_code part1 in Haskell module_name Day1 file_prefix "day1"

end