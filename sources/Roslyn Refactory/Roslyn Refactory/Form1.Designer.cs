namespace RoslynRefactory
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.newSolutionToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.openSolutionToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.saveSolutionToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.editToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.analyzeCodeToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.generateCodeToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.analyzeASTToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.renameToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.splitContainer3 = new System.Windows.Forms.SplitContainer();
            this.tvAst = new System.Windows.Forms.TreeView();
            this.tvNames = new System.Windows.Forms.TreeView();
            this.splitContainer2 = new System.Windows.Forms.SplitContainer();
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.splitContainer4 = new System.Windows.Forms.SplitContainer();
            this.propertyGrid1 = new System.Windows.Forms.PropertyGrid();
            this.tvFiles = new System.Windows.Forms.TreeView();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.tsStatus = new System.Windows.Forms.ToolStripStatusLabel();
            this.menuStrip1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer3)).BeginInit();
            this.splitContainer3.Panel1.SuspendLayout();
            this.splitContainer3.Panel2.SuspendLayout();
            this.splitContainer3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).BeginInit();
            this.splitContainer2.Panel1.SuspendLayout();
            this.splitContainer2.Panel2.SuspendLayout();
            this.splitContainer2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer4)).BeginInit();
            this.splitContainer4.Panel1.SuspendLayout();
            this.splitContainer4.Panel2.SuspendLayout();
            this.splitContainer4.SuspendLayout();
            this.statusStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.BackColor = System.Drawing.Color.White;
            this.menuStrip1.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.editToolStripMenuItem,
            this.toolsToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Padding = new System.Windows.Forms.Padding(4, 2, 0, 2);
            this.menuStrip1.Size = new System.Drawing.Size(812, 24);
            this.menuStrip1.TabIndex = 0;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.newSolutionToolStripMenuItem,
            this.openSolutionToolStripMenuItem,
            this.saveSolutionToolStripMenuItem,
            this.toolStripSeparator1});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // newSolutionToolStripMenuItem
            // 
            this.newSolutionToolStripMenuItem.Name = "newSolutionToolStripMenuItem";
            this.newSolutionToolStripMenuItem.Size = new System.Drawing.Size(150, 22);
            this.newSolutionToolStripMenuItem.Text = "New Solution";
            this.newSolutionToolStripMenuItem.Click += new System.EventHandler(this.File_NewSolution_Click);
            // 
            // openSolutionToolStripMenuItem
            // 
            this.openSolutionToolStripMenuItem.Name = "openSolutionToolStripMenuItem";
            this.openSolutionToolStripMenuItem.Size = new System.Drawing.Size(150, 22);
            this.openSolutionToolStripMenuItem.Text = "Open Solution";
            this.openSolutionToolStripMenuItem.Click += new System.EventHandler(this.File_OpenSolution_Click);
            // 
            // saveSolutionToolStripMenuItem
            // 
            this.saveSolutionToolStripMenuItem.Name = "saveSolutionToolStripMenuItem";
            this.saveSolutionToolStripMenuItem.Size = new System.Drawing.Size(150, 22);
            this.saveSolutionToolStripMenuItem.Text = "Save Solution";
            this.saveSolutionToolStripMenuItem.Click += new System.EventHandler(this.File_SaveSolution_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(147, 6);
            // 
            // editToolStripMenuItem
            // 
            this.editToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.analyzeCodeToolStripMenuItem,
            this.generateCodeToolStripMenuItem,
            this.analyzeASTToolStripMenuItem});
            this.editToolStripMenuItem.Name = "editToolStripMenuItem";
            this.editToolStripMenuItem.Size = new System.Drawing.Size(39, 20);
            this.editToolStripMenuItem.Text = "Edit";
            // 
            // analyzeCodeToolStripMenuItem
            // 
            this.analyzeCodeToolStripMenuItem.Name = "analyzeCodeToolStripMenuItem";
            this.analyzeCodeToolStripMenuItem.Size = new System.Drawing.Size(152, 22);
            this.analyzeCodeToolStripMenuItem.Text = "Analyze Code";
            this.analyzeCodeToolStripMenuItem.Click += new System.EventHandler(this.AnalyzeCode_Click);
            // 
            // generateCodeToolStripMenuItem
            // 
            this.generateCodeToolStripMenuItem.Name = "generateCodeToolStripMenuItem";
            this.generateCodeToolStripMenuItem.Size = new System.Drawing.Size(152, 22);
            this.generateCodeToolStripMenuItem.Text = "Generate Code";
            this.generateCodeToolStripMenuItem.Click += new System.EventHandler(this.GenerateCode_Click);
            // 
            // analyzeASTToolStripMenuItem
            // 
            this.analyzeASTToolStripMenuItem.Name = "analyzeASTToolStripMenuItem";
            this.analyzeASTToolStripMenuItem.Size = new System.Drawing.Size(152, 22);
            this.analyzeASTToolStripMenuItem.Text = "Analyze AST";
            this.analyzeASTToolStripMenuItem.Click += new System.EventHandler(this.AnalyzeAST_Click);
            // 
            // toolsToolStripMenuItem
            // 
            this.toolsToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.renameToolStripMenuItem});
            this.toolsToolStripMenuItem.Name = "toolsToolStripMenuItem";
            this.toolsToolStripMenuItem.Size = new System.Drawing.Size(46, 20);
            this.toolsToolStripMenuItem.Text = "Tools";
            // 
            // renameToolStripMenuItem
            // 
            this.renameToolStripMenuItem.Name = "renameToolStripMenuItem";
            this.renameToolStripMenuItem.Size = new System.Drawing.Size(117, 22);
            this.renameToolStripMenuItem.Text = "Rename";
            this.renameToolStripMenuItem.Click += new System.EventHandler(this.Rename_Click);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 24);
            this.splitContainer1.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.BackColor = System.Drawing.Color.White;
            this.splitContainer1.Panel1.Controls.Add(this.splitContainer3);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.splitContainer2);
            this.splitContainer1.Size = new System.Drawing.Size(812, 485);
            this.splitContainer1.SplitterDistance = 188;
            this.splitContainer1.SplitterWidth = 3;
            this.splitContainer1.TabIndex = 1;
            // 
            // splitContainer3
            // 
            this.splitContainer3.BackColor = System.Drawing.Color.Black;
            this.splitContainer3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer3.Location = new System.Drawing.Point(0, 0);
            this.splitContainer3.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.splitContainer3.Name = "splitContainer3";
            this.splitContainer3.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer3.Panel1
            // 
            this.splitContainer3.Panel1.BackColor = System.Drawing.Color.White;
            this.splitContainer3.Panel1.Controls.Add(this.tvAst);
            // 
            // splitContainer3.Panel2
            // 
            this.splitContainer3.Panel2.BackColor = System.Drawing.Color.White;
            this.splitContainer3.Panel2.Controls.Add(this.tvNames);
            this.splitContainer3.Size = new System.Drawing.Size(188, 485);
            this.splitContainer3.SplitterDistance = 212;
            this.splitContainer3.SplitterWidth = 3;
            this.splitContainer3.TabIndex = 0;
            // 
            // tvAst
            // 
            this.tvAst.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tvAst.Location = new System.Drawing.Point(0, 0);
            this.tvAst.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.tvAst.Name = "tvAst";
            this.tvAst.Size = new System.Drawing.Size(188, 212);
            this.tvAst.TabIndex = 3;
            this.tvAst.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.AstElement_Select);
            // 
            // tvNames
            // 
            this.tvNames.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tvNames.Location = new System.Drawing.Point(0, 0);
            this.tvNames.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.tvNames.Name = "tvNames";
            this.tvNames.Size = new System.Drawing.Size(188, 270);
            this.tvNames.TabIndex = 5;
            this.tvNames.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.NamesElement_Select);
            // 
            // splitContainer2
            // 
            this.splitContainer2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer2.Location = new System.Drawing.Point(0, 0);
            this.splitContainer2.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.splitContainer2.Name = "splitContainer2";
            // 
            // splitContainer2.Panel1
            // 
            this.splitContainer2.Panel1.BackColor = System.Drawing.Color.White;
            this.splitContainer2.Panel1.Controls.Add(this.textBox1);
            // 
            // splitContainer2.Panel2
            // 
            this.splitContainer2.Panel2.Controls.Add(this.splitContainer4);
            this.splitContainer2.Size = new System.Drawing.Size(621, 485);
            this.splitContainer2.SplitterDistance = 396;
            this.splitContainer2.SplitterWidth = 3;
            this.splitContainer2.TabIndex = 0;
            // 
            // textBox1
            // 
            this.textBox1.AcceptsReturn = true;
            this.textBox1.AcceptsTab = true;
            this.textBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textBox1.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textBox1.HideSelection = false;
            this.textBox1.Location = new System.Drawing.Point(0, 0);
            this.textBox1.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.textBox1.Multiline = true;
            this.textBox1.Name = "textBox1";
            this.textBox1.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.textBox1.Size = new System.Drawing.Size(396, 485);
            this.textBox1.TabIndex = 5;
            this.textBox1.Text = resources.GetString("textBox1.Text");
            // 
            // splitContainer4
            // 
            this.splitContainer4.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer4.Location = new System.Drawing.Point(0, 0);
            this.splitContainer4.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.splitContainer4.Name = "splitContainer4";
            this.splitContainer4.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer4.Panel1
            // 
            this.splitContainer4.Panel1.BackColor = System.Drawing.Color.White;
            this.splitContainer4.Panel1.Controls.Add(this.propertyGrid1);
            // 
            // splitContainer4.Panel2
            // 
            this.splitContainer4.Panel2.BackColor = System.Drawing.Color.White;
            this.splitContainer4.Panel2.Controls.Add(this.tvFiles);
            this.splitContainer4.Size = new System.Drawing.Size(222, 485);
            this.splitContainer4.SplitterDistance = 252;
            this.splitContainer4.SplitterWidth = 3;
            this.splitContainer4.TabIndex = 1;
            // 
            // propertyGrid1
            // 
            this.propertyGrid1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.propertyGrid1.Location = new System.Drawing.Point(0, 0);
            this.propertyGrid1.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.propertyGrid1.Name = "propertyGrid1";
            this.propertyGrid1.Size = new System.Drawing.Size(222, 252);
            this.propertyGrid1.TabIndex = 4;
            // 
            // tvFiles
            // 
            this.tvFiles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tvFiles.Location = new System.Drawing.Point(0, 0);
            this.tvFiles.Margin = new System.Windows.Forms.Padding(2, 2, 2, 2);
            this.tvFiles.Name = "tvFiles";
            this.tvFiles.Size = new System.Drawing.Size(222, 230);
            this.tvFiles.TabIndex = 7;
            this.tvFiles.AfterSelect += new System.Windows.Forms.TreeViewEventHandler(this.Files_Select);
            // 
            // statusStrip1
            // 
            this.statusStrip1.BackColor = System.Drawing.SystemColors.Highlight;
            this.statusStrip1.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.tsStatus});
            this.statusStrip1.Location = new System.Drawing.Point(0, 509);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Padding = new System.Windows.Forms.Padding(1, 0, 10, 0);
            this.statusStrip1.Size = new System.Drawing.Size(812, 22);
            this.statusStrip1.TabIndex = 2;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // tsStatus
            // 
            this.tsStatus.Name = "tsStatus";
            this.tsStatus.Size = new System.Drawing.Size(39, 17);
            this.tsStatus.Text = "Ready";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Black;
            this.ClientSize = new System.Drawing.Size(812, 531);
            this.Controls.Add(this.splitContainer1);
            this.Controls.Add(this.menuStrip1);
            this.Controls.Add(this.statusStrip1);
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "Form1";
            this.Text = "Roslyn Refactory";
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.splitContainer3.Panel1.ResumeLayout(false);
            this.splitContainer3.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer3)).EndInit();
            this.splitContainer3.ResumeLayout(false);
            this.splitContainer2.Panel1.ResumeLayout(false);
            this.splitContainer2.Panel1.PerformLayout();
            this.splitContainer2.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).EndInit();
            this.splitContainer2.ResumeLayout(false);
            this.splitContainer4.Panel1.ResumeLayout(false);
            this.splitContainer4.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer4)).EndInit();
            this.splitContainer4.ResumeLayout(false);
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.ToolStripMenuItem editToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem analyzeCodeToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem generateCodeToolStripMenuItem;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel tsStatus;
        private System.Windows.Forms.ToolStripMenuItem analyzeASTToolStripMenuItem;
        private System.Windows.Forms.SplitContainer splitContainer3;
        private System.Windows.Forms.TreeView tvAst;
        private System.Windows.Forms.TreeView tvNames;
        private System.Windows.Forms.ToolStripMenuItem toolsToolStripMenuItem;
        private System.Windows.Forms.SplitContainer splitContainer2;
        private System.Windows.Forms.TextBox textBox1;
        private System.Windows.Forms.SplitContainer splitContainer4;
        private System.Windows.Forms.TreeView tvFiles;
        private System.Windows.Forms.ToolStripMenuItem newSolutionToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem openSolutionToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem saveSolutionToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem renameToolStripMenuItem;
        private System.Windows.Forms.PropertyGrid propertyGrid1;
    }
}

