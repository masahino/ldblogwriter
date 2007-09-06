; ndiary-modeをベースに作成
;
(defcustom lbwriter-post-command "lbwriter"
  "blog投稿用コマンド. Emacsが実行可能なファイルである必要がある."
  :type 'filename
  :group 'lbwriter-mode)
(defcustom lbwriter-post-command-option ""  ; 未使用
  "blog投稿用のコマンドのオプション."
  :type 'string
  :group 'lbwriter-mode)

(defun lbwriter-mode ()
  (interactive)
  (setq major-mode 'lbwriter-mode)
  (setq mode-name "livedoorBlogWriter")
  (local-set-key "\C-c\C-c" 'lbwriter-post))

(defun lbwriter-post (arg)
  "ブログをポストする"
  (interactive "P")
  (let ((com lbwriter-post-command)
	(opt lbwriter-post-command-option)
	(filename buffer-file-name)
	proc)
    (basic-save-buffer) ; 実行前にbufferをsave
    (if (not (exec-installed-p lbwriter-post-command))
	(error "lbwriter-post-commandが正しく設定されていないようです."))
    (save-excursion
      (set-buffer (get-buffer-create "*lbwriter-post*"))
      (if (get-process "lbwriter-post")
	  (progn
	    (delete-process "lbwriter-post")))
      (erase-buffer)
      (setq proc (start-process
		  "lbwriter-post" "*lbwriter-post*" com filename))
      (set-process-filter proc 'lbwriter-post-filter)
      (display-buffer "*lbwriter-post*")
      )))

(defun lbwriter-post-filter (proc string)
  "lbwriter post filter"
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

  
