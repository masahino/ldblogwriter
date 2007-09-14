; ndiary-modeをベースに作成
;;
;; ndiary-mode.el --- mode for editing ndiary's diary file
;; ISHIKURA Hiroyuki <hiro@nekomimist.org>
;
(defcustom lbw-post-command "lbw"
  "blog投稿用コマンド. Emacsが実行可能なファイルである必要がある."
  :type 'filename
  :group 'lbw-mode)
(defcustom lbw-post-command-option ""  ; 未使用
  "blog投稿用のコマンドのオプション."
  :type 'string
  :group 'lbw-mode)
(defcustom lbw-yesterday-time 2
  "この時間(hour)を超えるまでは前日としてdiaryファイルを作成/取りあつかう."
  :type 'number
  :group 'lbw-mode)
(defcustom lbw-blog-directory "~/Diary"
  "日記の置いてあるディレクトリ."
  :type 'directory
  :group 'lbw-mode)
(defcustom lbw-split-month t
  "月毎にdiaryファイルを作成するディレクトリを分けるか否か."
  :type 'boolean
  :group 'lbw-mode)
(defcustom lbw-edit-hook nil nil
  :type 'hook
  :group 'lbw-mode)

(defun lbw-mode ()
  (interactive)
  (setq major-mode 'lbw-mode)
  (setq mode-name "livedoorBlogWriter")
  (local-set-key "\C-c\C-c" 'lbw-post))

(defun lbw-post (arg)
  "ブログをポストする"
  (interactive "P")
  (let ((com lbw-post-command)
	(opt lbw-post-command-option)
	(filename buffer-file-name)
	proc)
    (basic-save-buffer) ; 実行前にbufferをsave
    (if (not (exec-installed-p lbw-post-command))
	(error "lbw-post-commandが正しく設定されていないようです."))
    (save-excursion
      (set-buffer (get-buffer-create "*lbw-post*"))
      (if (get-process "lbw-post")
	  (progn
	    (delete-process "lbw-post")))
      (erase-buffer)
      (setq proc (start-process
		  "lbw-post" "*lbw-post*" com filename))
      (set-process-filter proc 'lbw-post-filter)
      (display-buffer "*lbw-post*")
      )))

(defun lbw-post-filter (proc string)
  "lbw post filter"
  (let ((buffer (process-buffer proc)))
    (set-buffer buffer)
    (insert string)
    (goto-char (point-max))
    (cond
     ((string-match "Username: " string)
      (setq input_str (read-string "Username: "))
      (process-send-string proc (concat input_str "\n")))
     ((string-match "Password: " string)
      (setq input_str (read-string "Password: "))
      (process-send-string proc (concat input_str "\n")))
     )))


; ndiary-mode.elを思いっきり参考に
; というか、ほとんどそのまんま
(defun lbw-edit-internal (time)
  "timeで示される日付の日記ファイルを編集する."
  (let (dir
	index)
    ;; ndiary-log-directoryがアクセス不能ならおしまい
    (if (not (file-accessible-directory-p lbw-blog-directory))
	(error "lbw-blog-directoryの設定が正しくないと思われます."))

    ;; 日記のファイル名を決定する
    (cond
     ((eq lbw-split-month t)
      (setq dir (expand-file-name
		 (format-time-string "%Y/%m" time) lbw-blog-directory))
      (if (not (file-accessible-directory-p dir))
	  (make-directory dir t)))
     (t
      (setq dir lbw-blog-directory)))

    ;; バッファを作る
    (setq index 1)
    (setq lbw-file-name (expand-file-name 
			 (format "%s-%d.txt" (format-time-string "%Y%m%d" time) index) dir))
    (while (file-exists-p lbw-file-name)
      (setq index (1+ index))
      (setq lbw-file-name (expand-file-name 
			   (format "%s-%d.txt"
				   (format-time-string "%Y%m%d" time) index) dir)))
    
    (setq lbw-buffer (find-file lbw-file-name)))
  (run-hooks 'lbw-edit-hook)
  (lbw-mode))

(defun lbw-edit (arg)
  "日記ファイルを編集する."
  (interactive "P")
  (let ((now (current-time)) (days 0) dateh datel daysec daysh daysl dir)
    ;; "今日"の日付の計算
    ;; ・hourがndiary-yesterday-time以前であれば1日前にずらす
    ;; ・引数あり呼出ならpromptを出し、入力された数値だけ「今」からずらす
    (if arg
	(setq days (floor (string-to-number
			   (read-from-minibuffer "offset: ")))))
    (setq daysec (* -1.0 days 60 60 24))
    (setq daysh (floor (/ daysec 65536.0)))
    (setq daysl (round (- daysec (* daysh 65536.0))))
    (setq dateh (- (nth 0 now) daysh))
    (setq datel (- (nth 1 now) (* lbw-yesterday-time 3600) daysl))
    (if (< datel 0)
	(progn
	  (setq datel (+ datel 65536))
	  (setq dateh (1- dateh))))
    (if (< dateh 0)
	(setq dateh 0))
    (setq now (list dateh datel))
    (lbw-edit-internal now)))

(provide 'lbw-mode)