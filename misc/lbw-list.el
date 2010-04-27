;; lbw-list.el

;;
(defcustom lbw-get-list-command "lbm"
  "エントリー取得コマンド"
  :type 'filename
  :group 'lbw-list)

(provide 'lbw-list)

(defvar lbw-list-mode-map nil)
(defvar lbw-list-buffer-name "*lbw list*")

(unless lbw-list-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map " " 'lbw-list-select-entry-or-scroll-up)
    (define-key map "m" 'lbw-list-mark)
    (define-key map "s" 'lbw-list-sync)
    (define-key map "q" 'lbw-list-exit)
    (setq lbw-list-mode-map map)))

(defun lbw-list (&rest args)
  "display list"
  (lbw-list-mode)
  (lbw-list-sync))

(defun lbw-list-sync()
  (interactive)
  (let ((buffer-read-only nil))
    (erase-buffer)
    (save-excursion
      (lbw-list-insert-entries))))


(defun lbw-list-insert-entriesX()
  (if (not (exec-installed-p lbw-get-list-command))
	(error "lbw-get-list-commandが正しく設定されていないようです."))
  (call-process lbw-get-list-command nil t))

(defun lbw-list-insert-entries()
  (setq entry-list (lbw-list-get-entry-list "/Users/masahino/Diary/entry_list.txt"))
  (dolist (entry entry-list)
    (let ((date (cdr (car entry)))
	  (title (cdr (cadr entry))))
      (insert date " " title "\n" ))))

(defun lbw-list-get-entry-list (file)
  (when (file-exists-p file)
    (with-temp-buffer
      (let (entry-list)
;      (insert-file-contents-literally file)
      (insert-file-contents file)
      (goto-char (point-min))
      (while (re-search-forward "\\(.+\\)\n\\(.+\\)\n\\(.+\\)\n\\(.+\\)\n\\(.+\\)\n" nil t)
	(let ((date (match-string 1))
	      (title (match-string 2))
	      (id (match-string 3))
	      (alternative-uri (match-string 4))
	      (edit-uri (match-string 5)))
	  (push (list (cons 'date date)
		      (cons 'title title)
		      (cons 'edit-uri edit-uri)) entry-list)))
      (nreverse entry-list)))))

(defun lbw-list-exit ()
  "exit lbw list"
  (interactive)
  (get-buffer lbw-list-buffer-name)
  (kill-buffer))

(defun lbw-list-mode ()
  "\\{lbw-list-mode-map}"
  (interactive)
  (if (get-buffer lbw-list-buffer-name)
      (switch-to-buffer lbw-list-buffer-name)
    (switch-to-buffer (get-buffer-create lbw-list-buffer-name))
    (kill-all-local-variables)
    (setq major-mode 'lbw-list-mode)
    (setq mode-name "lbw list")
    (setq buffer-read-only t)
    (buffer-disable-undo)
    (use-local-map lbw-list-mode-map)
    (lbw-list-sync)))

